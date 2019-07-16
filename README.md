# azure-dependabot

## Before you start

Import this repo in your Azure DevOps project and replace the following placeholders:

| Name | Description |
|--|--|
| `YOUR_ORG` | Your Azure DevOps Organisation (eg. Example) |
| `YOUR_PROJECT` | Your Azure DevOps Project (eg. Services) |
| `YOUR_REPO` | The repository to analyse and update (eg. awesome-service) |
| `YOUR_FEED` | The Azure Artifacts NuGet feed (eg. nuget.example) |
| `YOUR_DOMAIN` | Your domain (eg. example.com) |

## Running in Azure DevOps Pipelines

After replacing the placeholders above, simply create a new pipeline for the imported repo. Use the `azure-pipelines.yaml` as the source for the pipeline.

When the pipeline is run, `YOUR_REPO` will be analysed and PRs will be created for any out-of-date packages.

## Running locally in Docker

In addition to the placeholders above, replace the following: 

| Name | Description |
|--|--|
| `YOUR_AZURE_DEVOPS_PAT` | An access token with `Read`, `Create branch` and `Contribute to pull request` permissions to `YOUR_REPO` |

Running `docker build .` will analyse `YOUR_REPO`, creating PRs for any out-of-date packages.
