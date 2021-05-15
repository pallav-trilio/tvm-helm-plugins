#!/bin/bash
cd "$HELM_PLUGIN_DIR" || exit
version="$(grep  "version" plugin.yaml | cut -d '"' -f 2)"
echo "Installing tvm-upgrade ${version} ..."
# Find correct archive name
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)             os=linux;;
    Darwin*)            os=darwin;;
    MINGW*|MSYS_NT*)    os=windows;;
    Windows_NT)         os=windows;;
    *)                  os="UNKNOWN:${unameOut}";;
esac
archOut=$(uname -m)
case "${archOut}" in
    amd64*)             arch=amd64;;
    x86_64*)            arch=amd64;;
    386*)               arch=386;;
    *)                  arch=386;;
esac
if echo "$os" | grep -qe '.*UNKNOWN.*'
then
    echo "Unsupported OS / architecture: ${os}_${arch}"
    exit 1
fi
echo "OS/Arch : ${os}/$(arch)"
url="https://github.com/pallav-trilio/tvm-helm-plugins/blob/main/dist/tvm-upgrade_v0.0.0_${os}_${arch}.tar.gz?raw=true"
filename=$(echo "${url}" | sed -e "s/^.*\///g" | awk -F "?" '{print $1}')
echo "Filename : ${filename} "
  # Download archive
  if [[ -n "$(command -v curl)" ]]
  then
      curl -sSL -o "$filename" "$url" 
  elif [[ -n "$(command -v wget)" ]]
  then
      wget -q -O "$filename" "$url" 
  else
      echo "Need curl or wget"
      exit 1
  fi
echo "Downloaded Binary"
# Install bin
rm -rf bin && mkdir bin && tar xvf "$filename" -C bin > /dev/null && rm -f "$filename"