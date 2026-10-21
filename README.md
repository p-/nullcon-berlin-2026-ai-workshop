# Nullon Berlin 2026 AI Workshop


## Run Globals sample

```bash
python -m seclab_taskflow_agent -t ai_workshop.taskflows.ex1_globals -g fruit=apples
```



Execute existing [`fetch_source_code`](https://github.com/GitHubSecurityLab/seclab-taskflows/blob/main/src/seclab_taskflows/taskflows/audit/fetch_source_code.yaml) taskflow from [seclab-taskflows](https://github.com/GitHubSecurityLab/seclab-taskflows/) repo. (Those taskflows are linked as dependency)
```bash
python -m seclab_taskflow_agent -t seclab_taskflows.taskflows.audit.fetch_source_code -g repo=juice-shop/juice-shop
```