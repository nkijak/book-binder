# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

## Uploads
Add a book
```sh
curl --include \
    --request \
    POST http://localhost:3000/books \
    --form "book[title]=my title" \
    --form "book[book_archive]=@../tests/resources/book.tar.gz"
```

