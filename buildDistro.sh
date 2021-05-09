#!/bin/sh

echo "BOOK is /book"
echo "ls -l /book"
echo "CODE is /code"
echo "ls -l /code"
echo "IMAGES is /images"
echo "ls -l /images"

bundle exec asciidoctor         \
  --safe-mode unsafe            \
  --doctype book                \
  --destination-dir /output  \
  /book/raw.adoc

bundle exec asciidoctor-pdf     \
  --safe-mode unsafe            \
  --doctype book                \
  --destination-dir /output  \
  /book/raw.adoc

bundle exec asciidoctor-epub3   \
  --safe-mode unsafe            \
  --doctype book                \
  --destination-dir /output  \
  /book/raw.adoc

echo "OUTPUT is /output"
echo "ls -l /output"
