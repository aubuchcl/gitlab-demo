FROM gitlab/gitlab-runner:latest

ARG REGISTRATION_TOKEN

# Install any necessary dependencies
RUN apt-get update && apt-get install -y curl jq

# Copy the configuration file for GitLab Runner
COPY config.toml /etc/gitlab-runner/config.toml

# Environment variables for GitLab Runner registration
ENV CI_SERVER_URL=https://gitlab.com/
ENV RUNNER_NAME=cycle-function-runner
ENV RUNNER_EXECUTOR=shell
ENV RUNNER_TAG_LIST=my-tag
ENV REGISTRATION_TOKEN=${REGISTRATION_TOKEN}

# Replace the token placeholder in the config.toml.template
RUN sed -i "s/REPLACE_TOKEN/${REGISTRATION_TOKEN}/g" /etc/gitlab-runner/config.toml

# Register the runner with the shell executor
RUN gitlab-runner register --non-interactive \
    --url $CI_SERVER_URL \
    --registration-token $REGISTRATION_TOKEN \
    --name $RUNNER_NAME \
    --executor $RUNNER_EXECUTOR \
    --tag-list $RUNNER_TAG_LIST

ENTRYPOINT ["/entrypoint.sh"]

# Start the GitLab Runner
CMD ["gitlab-runner", "run", "--user=gitlab-runner", "--working-directory=/home/gitlab-runner"]
