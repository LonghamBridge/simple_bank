DB_URL=postgresql://root:secret@localhost:5432/simple_bank?sslmode=disable

postgres:
	docker run --name postgres15 --network bank_network -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=secret -d postgres:15-alpine

createdb:
	docker exec -it postgres15 createdb --username=root --owner=root simple_bank

dropdb:
	docker exec -it postgres15 dropdb simple_bank

execdb:
	docker exec -it postgres15 psql -U root -d simple_bank

migrateup:
	migrate -path db/migration -database "$(DB_URL)" -verbose up

migrateup1:
	migrate -path db/migration -database "$(DB_URL)" -verbose up 1

migratedown:
	migrate -path db/migration -database "$(DB_URL)" -verbose down

migratedown1:
	migrate -path db/migration -database "$(DB_URL)" -verbose down 1

db_docs:
	dbdocs build doc/db.dbml

db_schema:
	dbml2sql --postgres -o doc/schema.sql doc/db.dbml

sqlcinit:
	docker run --rm -v "F:\simple_bank:/src" -w /src kjconroy/sqlc:1.4.0 init	

sqlc:
	docker run --rm -v "F:\simple_bank:/src" -w /src kjconroy/sqlc:latest generate

# CMD -> docker run --rm -v "%cd%:/src" -w /src kjconroy/sqlc init			
# PS -> docker run --rm -v "$$(pwd):/src" -w /src kjconroy/sqlc init

test:
	go test -v -cover ./...

server:
	go run main.go

mock:
	mockgen -package mockdb -destination db/mock/store.go github.com/longhambridge/simple_bank/db/sqlc Store

proto:
	del /f /q "pb\*.go"
	del /f /q "doc\swagger\*.swagger.json"
	protoc --proto_path=proto --go_out=pb --go_opt=paths=source_relative \
 	--go-grpc_out=pb --go-grpc_opt=paths=source_relative \
	--grpc-gateway_out=pb --grpc-gateway_opt=paths=source_relative \
	--openapiv2_out=doc/swagger --openapiv2_opt=allow_merge=true,merge_file_name=simple_bank \
	proto/*.proto

# proto:
# 	rm -f pb/*.go
# 	rm -f doc/swagger/*.swagger.json
# 	protoc --proto_path=proto --go_out=pb --go_opt=paths=source_relative \
# 	--go-grpc_out=pb --go-grpc_opt=paths=source_relative \
# 	--grpc-gateway_out=pb --grpc-gateway_opt=paths=source_relative \
# 	--openapiv2_out=doc/swagger --openapiv2_opt=allow_merge=true,merge_file_name=simple_bank \
# 	proto/*.proto
# 	statik -src=./doc/swagger -dest=./doc

evans:
	evans --port 8888 -r repl

# dockerbuild:
# 	docker build -t simplebank:latest .

# dockerrun:
# 	docker run --name simple_bank --network bank_network -p 8080:8080 -e GIN_MODE=release -e DB_SOURCE="postgresql://root:secret@postgres15:5432/simple_bank?sslmode=disable" simple_bank:latest

# docker login:
# aws ecr get-login-password | docker login --username AWS --password-stdin 796108002880.dkr.ecr.us-east-1.amazonaws.com

.PHONY: postgres createdb dropdb migrateup migratedown migrateup1 migratedown1 db_docs db_schema sqlcinit sqlc test server mock proto evan dockerbuild dockerrun 