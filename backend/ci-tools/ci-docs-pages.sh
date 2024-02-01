#!/bin/bash

ls public/*

# copy rest-api and prepare
ls public/develop public/feature/* -al || echo "Develop REST docs empty"
mkdir public/$CI_COMMIT_BRANCH -p || echo "Specific Branch REST docs exists"
rm public/$CI_COMMIT_BRANCH/* -R || echo "SKIP CLEANING:Specific Branch REST docs still empty"
cp rest-api/build/docs/asciidoc/rest-api.html public/$CI_COMMIT_BRANCH/openfastlane-api.html || (echo "No rest docs on this Pipeline" && exit 1)
ls -al public/$CI_COMMIT_BRANCH/
echo "REST Doc URL is $CI_PAGES_URL/$CI_COMMIT_BRANCH/openfastlane-api.html"
