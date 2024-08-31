#!/usr/bin/env python

import json
import os
import time
import uuid
from typing import Any, Dict

import boto3
import pytest
from botocore.config import Config

_LAMBDA_FUNCTION_NAME = os.environ.get(
    "LAMBDA_FUNCTION_NAME", "lambda-hello-world"
)
_LAMBDA_DEAD_LETTER_QUEUE_NAME = os.environ.get(
    "LAMBDA_DEAD_LETTER_QUEUE_NAME", "dbl-dev-lambda-dead-letter-sqs-queue"
)
_LAMBDA_ON_SUCCESS_QUEUE_NAME = os.environ.get(
    "LAMBDA_ON_SUCCESS_QUEUE_NAME", "dbl-dev-lambda-on-success-sqs-queue"
)
_LAMBDA_ON_FAILURE_QUEUE_NAME = os.environ.get(
    "LAMBDA_ON_FAILURE_QUEUE_NAME", "dbl-dev-lambda-on-failure-sqs-queue"
)


@pytest.fixture(scope="function")
def lambda_client(
    connect_timeout: int = 60,
    read_timeout: int = 60,
    total_max_attempts: int = 1,
) -> Any:
    yield boto3.client(
        "lambda",
        config=Config(
            connect_timeout=connect_timeout,
            read_timeout=read_timeout,
            retries={"total_max_attempts": total_max_attempts},
        ),
    )


@pytest.fixture(scope="function")
def sqs_client() -> Any:
    yield boto3.client("sqs")


@pytest.fixture(scope="function")
def sqs_queue_urls() -> Dict[str, str]:
    account_id = boto3.client('sts').get_caller_identity()['Account']
    region = boto3.session.Session().region_name
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
    assert response["StatusCode"] == 200
    assert response["ResponseMetadata"]["HTTPStatusCode"] == 200
    response_payload = json.loads(response["Payload"].read().decode())
    assert response_payload.get("message")
    assert response_payload.get("event") == input_event


def test_lambda_asynchronous_invocation(
    lambda_client: Any,
    sqs_client: Any,
    sqs_queue_urls: Dict[str, str],
    max_attempts: int = 10,
    delay: int = 1,
) -> None:
    input_event = {"job_id": str(uuid.uuid4())}
    response = lambda_client.invoke(
        FunctionName=_LAMBDA_FUNCTION_NAME,
        InvocationType="Event",
        Payload=json.dumps(input_event),
    )
    assert response["StatusCode"] == 202
    assert response["ResponseMetadata"]["HTTPStatusCode"] == 202
    assert response["Payload"].read() == b""
    execution_id = response['ResponseMetadata']['RequestId']
    result: Dict[str, Any] = {}
    for _ in range(max_attempts):
        if not result:
            time.sleep(delay)
            for q, u in sqs_queue_urls.items():
                messages = sqs_client.receive_message(
                    QueueUrl=u,
                    MaxNumberOfMessages=1,
                    WaitTimeSeconds=1
                ).get('Messages', [])
                for m in messages:
                    body = json.loads(m['Body'])
                    if body['requestContext']['requestId'] == execution_id:
                        result[q] = body
                        sqs_client.delete_message(
                            QueueUrl=u, ReceiptHandle=m['ReceiptHandle']
                        )
    assert "dead_letter" not in result
    assert "on_failure" not in result
    assert result.get("on_success")
    assert result["on_success"].get("message")
    assert result["on_success"].get("event") == input_event
