#!/bin/bash

jazzy \
  --author 'Chris Araman' \
  --author_url https://github.com/chris-araman \
  --clean \
  --github_url https://github.com/chris-araman/CombineCloudKit \
  --github-file-prefix https://github.com/chris-araman/CombineCloudKit/tree/$(git rev-parse HEAD) \
  --module CombineCloudKit \
  --module-version $(git describe --tags) \
  --output docs \
  --theme fullwidth
