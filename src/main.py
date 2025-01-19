#!/usr/bin/env python

import json
from typing import Any

from aws_lambda_powertools import Logger, Tracer

logger = Logger()
tracer = Tracer()


@logger.inject_lambda_context(log_event=True)
@tracer.capture_lambda_handler
def lambda_handler(event: dict[str, Any], context: Any) -> dict[str, Any]:
    logger.info(f"event: {event}")
    logger.info(f"context: {vars(context)}")
    body_dict = {
        "message": "Hello World!",
        "event": event,
        "context_invoked_function_arn": context.invoked_function_arn,
        "context_log_stream_name": context.log_stream_name,
        "context_log_group_name": context.log_group_name,
        "context_aws_request_id": context.aws_request_id,
        "context_memory_limit_in_mb": context.memory_limit_in_mb,
    }
    logger.info(f"body_dict: {body_dict}")
    return {"statusCode": 200, "body": json.dumps(body_dict)}
