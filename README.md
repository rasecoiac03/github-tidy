# Github Tidy

Tidy Github organization.

- Repositories
  - Backup to Amazon S3, delete from Github and notify to Slack

**TODO (Future)**
- Issues (future)
- Pull Requests (future)
...

## Usage

### Repositories

#### AWS S3 Backup and delete

- With repository name
```sh
github-tidy [github organization] [s3 bucket] [repository]
```

- Exporting a variable
```sh
export PROJECTS=$(cat <<-END
project1
project2
END
github-tidy [github organization] [s3 bucket]
```

- With a file containing repositories name
```sh
github-tidy [github organization] [s3 bucket] [file with repositories names]
```

## Helping out

Ideas/Suggestions? Complaints? Create an issue or a pull request :D
