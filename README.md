# Nullon Berlin 2026 AI Workshop


## Run Globals sample

```bash
python -m seclab_taskflow_agent -t ai_workshop.taskflows.ex1_globals -g fruit=apples
```


## Run existing fetch source code taskflow

Execute existing [`fetch_source_code`](https://github.com/GitHubSecurityLab/seclab-taskflows/blob/main/src/seclab_taskflows/taskflows/audit/fetch_source_code.yaml) taskflow from [seclab-taskflows](https://github.com/GitHubSecurityLab/seclab-taskflows/) repo. (Those taskflows are linked as dependency)
```bash
python -m seclab_taskflow_agent -t seclab_taskflows.taskflows.audit.fetch_source_code -g repo=pallets/flask
```

```bash
python -m seclab_taskflow_agent -t seclab_taskflows.taskflows.audit.fetch_security_advisories -g repo=pallets/flask
```

```bash
python -m seclab_taskflow_agent -t ai_workshop.taskflows.ex4_variant_finder -g repo=pallets/flask
```