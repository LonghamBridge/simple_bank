postgres:
	docker run --name postgres15 -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=secret -d postgres:15-alpine

createdb:
	docker exec -it postgres15 createdb --username=root --owner=root simple_bank

dropdb:
	docker exec -it postgres15 dropdb simple_bank

execdb:
	docker exec -it postgres15 psql -U root -d simple_bank

migrateup:
	migrate -path db/migration -database "postgresql://root:secret@localhost:5432/simple_bank?sslmode=disable" -verbose up

migratedown:
	migrate -path db/migration -database "postgresql://root:secret@localhost:5432/simple_bank?sslmode=disable" -verbose down

sqlcinit:
	docker run --rm -v "F:\simple_bank:/src" -w /src kjconroy/sqlc:1.4.0 init	

sqlc:
	docker run --rm -v "F:\simple_bank:/src" -w /src kjconroy/sqlc:1.4.0 generate

# CMD -> docker run --rm -v "%cd%:/src" -w /src kjconroy/sqlc init			
# PS -> docker run --rm -v "$$(pwd):/src" -w /src kjconroy/sqlc init

test:
	go test -v -cover ./...


.PHONY: postgres createdb dropdb migrateup migratedown sqlcinit sqlc test