# Use an official Ruby runtime as a parent image
FROM ruby:3.2.2-alpine

# Set the working directory in the container to /app
WORKDIR /app

# Add the current directory contents into the container at /app
ADD . /app

# Install any needed packages specified in Gemfile
RUN bundle install
