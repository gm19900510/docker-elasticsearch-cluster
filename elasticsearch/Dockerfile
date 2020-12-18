ARG ES_VERSION=7.9.3

# https://github.com/elastic/elasticsearch-docker
# FROM docker.elastic.co/elasticsearch/elasticsearch:${ES_VERSION}
FROM elasticsearch:${ES_VERSION}
# Add your elasticsearch plugins setup here
# Example: RUN elasticsearch-plugin install analysis-icu
# RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install https://github.com/medcl/elasticsearch-analysis-pinyin/releases/download/v7.9.3/elasticsearch-analysis-pinyin-7.9.3.zip
ADD plugins/elasticsearch-analysis-ik /usr/share/elasticsearch/plugins/elasticsearch-analysis-ik
ADD plugins/elasticsearch-analysis-pinyin /usr/share/elasticsearch/plugins/elasticsearch-analysis-pinyin

