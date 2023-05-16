# Youtube API V3 Crawler

## How to get API Token?
- Go to https://developers.google.com/youtube/v3/getting-started#before-you-start

## To run app in Docker container:
- Clone repo: `git clone https://github.com/popovycj/youtube-api-crawler.git`
- Change directory: `cd youtube-api-crawler`
- Build docker image: `docker build -t <your image name> .`
- Run docker container with your parameters: `docker run -it --rm -e YOUTUBE_DEVELOPER_KEY='<your token>' -v $(pwd):/app -w /app <your image name> ruby youtube_crawler.rb --q="<your quote>" --max-results=<your number>`
