#!/usr/bin/env python

import json
from typing import Any, Dict


def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    return {
        "statusCode": 200,
        "body": json.dumps(
            {
                "message": "Hello World!",
                "event": event,
                "context": vars(context),
            }
        ),
    }
