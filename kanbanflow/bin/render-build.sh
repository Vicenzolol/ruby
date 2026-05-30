#!/usr/bin/env bash
# bin/render-build.sh — Script de build executado pelo Render a cada deploy
# Documentação: https://render.com/docs/deploy-rails-8#create-a-build-script
set -o errexit

bundle install

# Pré-compila assets (Tailwind + Propshaft)
bin/rails assets:precompile

# Remove assets antigos (mantém apenas os digest-stamped atuais)
bin/rails assets:clean

# Executa migrations do banco de dados
# Nota: em planos pagos, mover db:migrate para o "pre-deploy command" no Render
# para que rode ANTES da nova versão entrar em produção (zero-downtime).
bin/rails db:migrate
