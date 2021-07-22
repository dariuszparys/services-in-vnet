import logging
import requests

import azure.functions as func


def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    url = req.params.get('url')
    if not url:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            url = req_body.get('url')

    if url:
        response = requests.get(url)
        if response.status_code == 200:
            return func.HttpResponse(response.text)
        else:
            return func.HttpResonse(f"Http status code is {response.status_code}")            
    else:
        return func.HttpResponse("no url parameter provided")
