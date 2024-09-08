# Decisions

## List of Decisions

### DIAP-2024090801 Monorepo for all AWS infrastructure supporting apps

Apps need things like buckets, databases, etc. just for them. This is the place to put all that infrastructure. An
argument can be made for having separate repos for each app, but for this hobby/skills showcase, this is a sufficient
simplification. The platform supports having a separate repo per app, or hosting the IaC within the app's source code
repo.
