# Cypress End to End 
## Docker image to integrate with your CI process

Using the image of **Centos7** all the necessary dependencies for the execution of Cypress are installed.

Integrated with Mochawesome and available to test with **Chrome** and **Electron**.

>*Firefox* is preconfigured for when Cypress has it supported.
---

### Build image
~~~
docker build -t cypress-env ./docker/
~~~
---

### Run Container
You have to provide the directory where all your *.spec.js are. 

For example:
~~~
docker run -v $(pwd)/webpublic-test/:/opt/cypressEnv/cypress/integration cypress-env:latest
~~~

By **default** it runs with **Electron**, you can change the browser by adding:
~~~
docker run -v $(pwd)/webpublic-test/:/opt/cypressEnv/cypress/integration -e "BROWSER=chrome" cypress-env:latest
~~~