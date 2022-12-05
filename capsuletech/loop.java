    do{
        HttpResponse response = httpClient.execute(request);
        HttpEntity responseEntity = response.getEntity();
        String content = EntityUtils.toString(responseEntity);
        // Check 2XX code.
        statusCode = response.getStatusLine().getStatusCode();
        if ((statusCode / 100 == 2)) {
            break;
        }
        if (!(statusCode / 100 == 2) && count > countMax) {
            throw HealthcareHttpException.of(statusCode, content);
        }
        LOG.warn(
            String.format(
                "Bad response in executeFhirBundle: %s in loop try #%s", statusCode, count));
        count++;
        Thread.sleep(sleepValMs);
        sleepValMs*=2;
    }while(!(statusCode / 100 == 2))
