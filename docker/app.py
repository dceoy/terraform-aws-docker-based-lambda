#!/usr/bin/env python

import json
import logging
from typing import Any, Dict


def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    logger = logging.getLogger(lambda_handler.__name__)
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
