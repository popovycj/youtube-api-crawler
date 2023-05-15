# Youtube API V3 Crawler

## To run app in Docker container:
- Build docker image: `docker build -t <your image name> .`
- Run docker container with your parameters: `docker run -it --rm -e YOUTUBE_DEVELOPER_KEY='<your token>' -v $(pwd):/app -w /app <your image name> ruby youtube_crawler.rb --q="<your quote>" --max-results=<your number>`
