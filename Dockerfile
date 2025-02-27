FROM golang:1.23-alpine as builder

WORKDIR /app

COPY ./go.* ./

RUN go mod download

COPY ./ ./

RUN CGO_ENABLED=0 go build -a --trimpath --installsuffix cgo --ldflags="-s" -o main ./main.go

FROM scratch

COPY --from=builder /app/main ./

CMD [ "./main" ]