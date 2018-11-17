# Cypress End to End 
## Docker image to integrate with your CI process

Based on an image of **Centos7** with all the necessary dependencies for the execution of Cypress are installed.

It is integrated with **Mochawesome**. 

The available browsers are **Chrome** and **Electron**.

>*Firefox* is preconfigured for when Cypress has it supported.

It is possible to have the **configuration** stored in **Parameter Store** and upload the test execution **report** to **S3** and **Cloudwatch**.

---

### Build image
~~~
docker build -t cypress-env ./docker/
~~~
---
## Run Container
### Configuration files
Parameter store is used to download the test execution configuration. The files [cypress.json](https://docs.cypress.io/guides/references/configuration.html#Options) and [cypress.env.json](https://docs.cypress.io/guides/guides/environment-variables.html#Option-2-cypress-env-json) must be in a variable and saved in **base64**.

The variable can be either **String** or **SecureString**. Given a json file the following command must be executed to obtain the string to store in Parameter Store:

~~~
base64 cypress.json
~~~
---
### Submit test specs

You have to provide the directory where all your ***.spec.js** are. 

For example:
~~~
docker run -v $(pwd)/test-directory/:/opt/cypressEnv/cypress/integration cypress-env:latest
~~~

You can also use **S3_SOURCE** parameter to give it a bucket to download the tests from.

---
### Execution Parameters

* **BROWSER**: electron *(default)* | chrome | firefox *([soon™](https://www.urbandictionary.com/define.php?term=soon%E2%84%A2))*
* **CYPRESS_CONF**: Parameter Store variable where the cypress.json file is stored.
* **CYPRESS_ENV**: Parameter Store variable where the cypress.env.json file is stored.
* **REGION**: AWS region.
* **S3_REPORTS**: S3 bucket where store the result of the execution of the tests.
* **S3_SOURCE**: S3 bucket where store the tests specs.
* **NAMESPACE**: Namespace of Cloudwatch metrics.
* **METRIC_OK**: Metric where to store the results of completed tests.
* **METRIC_KO**: Metric where to store the result of failed tests.
* **DIMENSIONS**: Optional Cloudwatch parameter to specify metrics dimensions.

It is **recommended** to specify the parameter **REGION** always.

If you want to dump the result to Cloudwatch, the three parameters **NAMESPACE**, **METRIC_OK** and **METRIC_KO** must be specified. 
>CloudWatch only works with Mochawesome reporter.

#### Examples
Example cypress.json with Mochawesome and Electron 
~~~
{
    "viewportHeight": 1080,
    "viewportWidth": 1200,
    "video": false,
    "reporter": "mochawesome",
    "reporterOptions": {
        "overwrite": false, //important when you have multiple tests suites
        "html": true,
        "json": true,
        "cdn": true
    }  
}
~~~

Run local tests
~~~
docker run -v $(pwd)/test-directory/:/opt/cypressEnv/cypress/integration \
           -e "BROWSER=chrome" \
           -e "CYPRESS_CONF=/cypress/config" \
           -e "CYPRESS_ENV=/cypress/env" \
           -e "REGION=eu-west-1" \
           -e "S3_REPORTS=cypressReports" \
           -e "NAMESPACE=cypressMetrics" \
           -e "METRIC_OK=metricOk" \
           -e "METRIC_KO=metricKo" \
           cypress:latest
~~~

Run S3 tests
~~~
docker run -e "BROWSER=chrome" \
           -e "CYPRESS_CONF=/cypress/config" \
           -e "CYPRESS_ENV=/cypress/env" \
           -e "REGION=eu-west-1" \
           -e "S3_REPORTS=cypressReports" \
           -e "S3_SOURCE=cypressTests/release_1" \
           -e "NAMESPACE=cypressMetrics" \
           -e "METRIC_OK=metricOk" \
           -e "METRIC_KO=metricKo" \
           -e "DIMENSIONS=project=my-project,release=1.2" \
           cypress:latest
~~~
---
# TODO
* Build the CI/CD pipeline