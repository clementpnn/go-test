FROM golang:1.23-alpine as builder

ARG TARGETARCH
ARG APP_RELEASE

WORKDIR /app

COPY ./go.* ./
RUN go mod download

COPY ./ ./

RUN CGO_ENABLED=0 GOOS=linux GOARCH=${TARGETARCH} go build -a --trimpath --installsuffix cgo --ldflags="-s" -o main ./main.go

FROM scratch

ARG APP_RELEASE
LABEL app.release=$APP_RELEASE

COPY --from=builder /app/main ./

CMD [ "./main" ]
