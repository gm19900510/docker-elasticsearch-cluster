#/bin/bash
mkdir -p elasticsearch/config
mkdir elasticsearch/{data1,data2,data3}
echo 'ES_VERSION=7.9.3' > .env
mkdir -p elasticsearch/plugins
cd elasticsearch/plugins
wget https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v7.9.3/elasticsearch-analysis-ik-7.9.3.zip
wget https://github.com/medcl/elasticsearch-analysis-pinyin/releases/download/v7.9.3/elasticsearch-analysis-pinyin-7.9.3.zip
unzip elasticsearch-analysis-ik-7.9.3.zip -d elasticsearch-analysis-ik
unzip elasticsearch-analysis-pinyin-7.9.3.zip -d elasticsearch-analysis-pinyin


