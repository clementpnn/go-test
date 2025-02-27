FROM golang:1.23-alpine as builder

# Ces arguments seront injectés par Buildx
ARG TARGETARCH
ARG APP_RELEASE

WORKDIR /app

COPY ./go.* ./
RUN go mod download

COPY ./ ./

# Compiler pour la plateforme cible
RUN CGO_ENABLED=0 GOOS=linux GOARCH=${TARGETARCH} go build -a --trimpath --installsuffix cgo --ldflags="-s" -o main ./main.go

FROM scratch
# Propager APP_RELEASE dans l'image finale (optionnel : pour ajouter un label)
ARG APP_RELEASE
LABEL app.release=$APP_RELEASE

COPY --from=builder /app/main ./

CMD [ "./main" ]
