# Lambda Error Level

Lambda now supports advanced logging configurations that allow CloudWatch logs to only ingest logs of a certain level based on the `level` attribute in a JSON-structured log payload.

This doesn't work with `aws-lambda-go` because improperly-shaped logs are automatically assigned to the `INFO` level.

## Reproduce

```
make build
sam deploy --guided
```

The defaults for SAM setup should be fine. This will set both system an application log levels to `INFO`.

Invoke the Lambda function (it will error, that's intended) in the stack, then open the CloudWatch Logs for the function. There will be a number of log entries, but there are two that are important:

```json
{
  "time": "2023-11-17T18:52:05.505403525Z",
  "level": "INFO",
  "msg": "{\"errorMessage\":\"runtime error: index out of range [1] with length 1\",\"errorType\":\"boundsError\",\"stackTrace\":[{\"path\":\"github.com/aws/aws-lambda-go@v1.41.0/lambda/errors.go\",\"line\":39,\"label\":\"lambdaPanicResponse\"},{\"path\":\"github.com/aws/aws-lambda-go@v1.41.0/lambda/invoke_loop.go\",\"line\":116,\"label\":\"callBytesHandlerFunc.func1\"},{\"path\":\"runtime/panic.go\",\"line\":914,\"label\":\"gopanic\"},{\"path\":\"runtime/panic.go\",\"line\":114,\"label\":\"goPanicIndex\"},{\"path\":\"logme/main.go\",\"line\":24,\"label\":\"handler\"},{\"path\":\"logme/main.go\",\"line\":49,\"label\":\"handlerWithLambdaLogging[...].func1\"},{\"path\":\"reflect/value.go\",\"line\":596,\"label\":\"Value.call\"},{\"path\":\"reflect/value.go\",\"line\":380,\"label\":\"Value.Call\"},{\"path\":\"github.com/aws/aws-lambda-go@v1.41.0/lambda/handler.go\",\"line\":293,\"label\":\"reflectHandler.func2\"},{\"path\":\"github.com/aws/aws-lambda-go@v1.41.0/lambda/invoke_loop.go\",\"line\":119,\"label\":\"callBytesHandlerFunc\"},{\"path\":\"github.com/aws/aws-lambda-go@v1.41.0/lambda/invoke_loop.go\",\"line\":75,\"label\":\"handleInvoke\"},{\"path\":\"github.com/aws/aws-lambda-go@v1.41.0/lambda/invoke_loop.go\",\"line\":39,\"label\":\"startRuntimeAPILoop\"},{\"path\":\"github.com/aws/aws-lambda-go@v1.41.0/lambda/entry.go\",\"line\":106,\"label\":\"start\"},{\"path\":\"github.com/aws/aws-lambda-go@v1.41.0/lambda/entry_generic.go\",\"line\":20,\"label\":\"StartHandlerFunc[...]\"},{\"path\":\"logme/main.go\",\"line\":14,\"label\":\"main\"},{\"path\":\"runtime/proc.go\",\"line\":267,\"label\":\"main\"},{\"path\":\"runtime/asm_arm64.s\",\"line\":1197,\"label\":\"goexit\"}]}",
  "requestId": "122704c2-24e7-4cdd-860d-27388e00f396"
}
```

and

```json
{
  "time": "2023-11-17T18:52:05.506301428Z",
  "level": "INFO",
  "msg": "calling the handler function resulted in a panic, the process should exit",
  "requestId": "122704c2-24e7-4cdd-860d-27388e00f396"
}
```

Notice these are `INFO`-level. This is because `aws-lambda-go` doesn't structure the logs and Lambda automatically shapes unstructured logs this way if it's unspecified.

If you switch `ApplicationLogLevelParameter` to `ERROR` in the CloudFormation stack and update it and re-run the function, the error log entries will be omitted (because they're `INFO`-level).
