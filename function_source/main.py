import functions_framework
import flask

@functions_framework.http
def helloWorld(request: flask.Request) -> flask.Response:
    from flask import abort

    response = "Hello, World!"

    if request.method == "GET":
        return flask.Response(response, mimetype="text/plain")
    elif request.method == "POST":
        return abort(501)
    else:
        return abort(405)
