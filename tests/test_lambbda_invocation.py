#!/usr/bin/env python

import json
import os
import time
import uuid
from typing import Any

import boto3
import pytest
from botocore.config import Config

_LAMBDA_FUNCTION_NAME = os.environ.get("LAMBDA_FUNCTION_NAME", "lambda-hello-world")
_LAMBDA_DEAD_LETTER_QUEUE_NAME = os.environ.get(
    "LAMBDA_DEAD_LETTER_QUEUE_NAME", "dbl-dev-lambda-dead-letter-sqs-queue"
)
_LAMBDA_ON_SUCCESS_QUEUE_NAME = os.environ.get(
    "LAMBDA_ON_SUCCESS_QUEUE_NAME", "dbl-dev-lambda-on-success-sqs-queue"
)
_LAMBDA_ON_FAILURE_QUEUE_NAME = os.environ.get(
    "LAMBDA_ON_FAILURE_QUEUE_NAME", "dbl-dev-lambda-on-failure-sqs-queue"
)


@pytest.fixture
def lambda_client(
    connect_timeout: int = 60,
    read_timeout: int = 60,
    total_max_attempts: int = 1,
) -> Any:
    return boto3.client(
        "lambda",
        config=Config(
            connect_timeout=connect_timeout,
            read_timeout=read_timeout,
            retries={"total_max_attempts": total_max_attempts},
        ),
    )


@pytest.fixture
def sqs_client() -> Any:
    return boto3.client("sqs")


@pytest.fixture
def sqs_queue_urls() -> dict[str, str]:
    account_id = boto3.client("sts").get_caller_identity()["Account"]
    region = boto3.session.Session().region_name  # pyright: ignore[reportAttributeAccessIssue]
    url_prefix = f"https://sqs.{region}.amazonaws.com/{account_id}/"
    return {
        "dead_letter": f"{url_prefix}{_LAMBDA_DEAD_LETTER_QUEUE_NAME}",
        "on_success": f"{url_prefix}{_LAMBDA_ON_SUCCESS_QUEUE_NAME}",
        "on_failure": f"{url_prefix}{_LAMBDA_ON_FAILURE_QUEUE_NAME}",
    }


def test_lambda_synchronous_invocation(lambda_client: Any) -> None:
    input_event = {"job_id": str(uuid.uuid4())}
    response = lambda_client.invoke(
        FunctionName=_LAMBDA_FUNCTION_NAME,
        InvocationType="RequestResponse",
        Payload=json.dumps(input_event),
    )
    status_code = 200
    assert response["StatusCode"] == status_code
    assert response["ResponseMetadata"]["HTTPStatusCode"] == status_code
    response_payload = json.loads(response["Payload"].read().decode())
    assert response_payload.get("message")
    assert response_payload.get("event") == input_event


def test_lambda_asynchronous_invocation(
    lambda_client: Any,
    sqs_client: Any,
    sqs_queue_urls: dict[str, str],
) -> None:
    polling_interval = 1
    polling_timeout = 900
    input_event = {"job_id": str(uuid.uuid4())}
    response = lambda_client.invoke(
        FunctionName=_LAMBDA_FUNCTION_NAME,
        InvocationType="Event",
        Payload=json.dumps(input_event),
    )
    status_code = 202
    assert response["StatusCode"] == status_code
    assert response["ResponseMetadata"]["HTTPStatusCode"] == status_code
    assert response["Payload"].read() == b""
    execution_id = response["ResponseMetadata"]["RequestId"]
    message_bodies: dict[str, Any] = {}
    deadline_time = time.time() + polling_timeout
    while time.time() < deadline_time:
        for q, u in sqs_queue_urls.items():
            r = sqs_client.receive_message(
                QueueUrl=u, MaxNumberOfMessages=1, WaitTimeSeconds=1
            )
            for m in r.get("Messages", []):
                b = json.loads(m["Body"])
                if b["requestContext"]["requestId"] == execution_id:
                    message_bodies[q] = b
                    sqs_client.delete_message(
                        QueueUrl=u, ReceiptHandle=m["ReceiptHandle"]
                    )
        if message_bodies:
            break
        else:
            time.sleep(polling_interval)
    assert "dead_letter" not in message_bodies
    assert "on_failure" not in message_bodies
    assert message_bodies.get("on_success")
    assert message_bodies["on_success"].get("message")
    assert message_bodies["on_success"].get("event") == input_event
