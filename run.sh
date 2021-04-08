#!/bin/bash

LANG=en_US.UTF-8
LC_ALL=en_US.UTF-8

cd $(dirname $0)
base_dir=$(pwd)

jaf111_file=activation-1.1.1-sources.jar
jaf111_url=https://repo1.maven.org/maven2/javax/activation/activation/1.1.1/activation-1.1.1-sources.jar
jaf120_file=javax.activation-api-1.2.0-sources.jar
jaf120_url=https://repo1.maven.org/maven2/javax/activation/javax.activation-api/1.2.0/javax.activation-api-1.2.0-sources.jar
jaf122_file=jakarta.activation-api-1.2.2-sources.jar
jaf122_url=https://repo1.maven.org/maven2/jakarta/activation/jakarta.activation-api/1.2.2/jakarta.activation-api-1.2.2-sources.jar
jaf201_file=jakarta.activation-api-2.0.1-sources.jar
jaf201_url=https://repo1.maven.org/maven2/jakarta/activation/jakarta.activation-api/2.0.1/jakarta.activation-api-2.0.1-sources.jar

download_file() {
  jaf_file=$1
  jaf_url=$2
  if [[ ! -f ${jaf_file} ]] ; then
    curl -o ${base_dir}/${jaf_file} ${jaf_url}
  fi
}

download_file $jaf111_file $jaf111_url
download_file $jaf120_file $jaf120_url
download_file $jaf122_file $jaf122_url
download_file $jaf201_file $jaf201_url

diff_files() {
  jaf1_file=$1
  jaf2_file=$2
  output_file=$3
  jaf1_dir=$(echo ${jaf1_file} | sed -e "s/-sources.jar//")
  jaf2_dir=$(echo ${jaf2_file} | sed -e "s/-sources.jar//")
  tmp1_file=/tmp/jaf1.$$
  tmp2_file=/tmp/jaf2.$$
  rm -rf ${jaf1_dir} ${jaf2_dir}
  mkdir ${jaf1_dir} ${jaf2_dir}
  cd ${jaf1_dir}
  unzip ${base_dir}/${jaf1_file}
  find * -type f | sort > ${tmp1_file}
  cd ..
  cd ${jaf2_dir}
  unzip ${base_dir}/${jaf2_file}
  find * -type f | sort > ${tmp2_file}
  cd ..

  echo "<<<${jaf1_file}>>>" > ${output_file}
  cat ${tmp1_file} >> ${output_file}
  echo >> ${output_file}
  echo "<<<${jaf2_file}>>>" >> ${output_file}
  cat ${tmp2_file} >> ${output_file}
  echo >> ${output_file}
  echo "<<<Files: ${jaf1_file} - ${jaf2_file}>>>" >> ${output_file}
  diff -u ${tmp1_file} ${tmp2_file} >> ${output_file}
  echo >> ${output_file}
  echo "<<<Contents: ${jaf1_dir} - ${jaf2_dir}>>>" >> ${output_file}
  diff -ubr ${jaf1_dir} ${jaf2_dir} >> ${output_file}

  rm ${tmp1_file} ${tmp2_file}
}

diff_files $jaf111_file $jaf120_file ${base_dir}/111_120.txt
diff_files $jaf120_file $jaf122_file ${base_dir}/120_122.txt
diff_files $jaf122_file $jaf201_file ${base_dir}/122_201.txt
