# Atividade Docker + CI — Felipe da Silva Spinola

**Aluno(a):** Felipe da Silva Spinola  
**Turma:** Noturno  
**Data:** 27/07/2026  
**Aplicação usada:** `docker/getting-started-app` — To-Do em Node.js  

---

## 1. Como executar este projeto

```bash
git clone https://github.com/Fesisp/meu-projeto-docker
cd meu-projeto-docker
cp .env.example .env
docker compose up -d --build
```

- **Acesse no navegador:** `http://localhost:3000`
- **Para derrubar (mantendo dados):** `docker compose down`
- **Para derrubar (apagando dados):** `docker compose down -v`

---

## 2. Imagem e Dockerfile multi-stage

- **Estágios utilizados:** `builder` (para instalar dependências) e estágio final de runtime (enxuto para execução)
- **Imagem base:** `node:20-alpine`
- **Usuário de execução:** `node` (não-root)
- **Tamanho final da imagem:** `~180MB`

> **Por que o multi-stage ajuda?**  
> O multi-stage build permite separar o ambiente de compilação/instalação de dependências do ambiente de execução final, resultando em imagens significativamente menores (sem ferramentas de build desnecessárias) e muito mais seguras por reduzir a superfície de ataque e rodar com usuário não-root.

---

## 3. Volumes e persistência

- **Volume usado:** `todo-db` → montado em `/etc/todos` dentro do container.

> **Diferença entre docker compose down e docker compose down -v:**  
> O comando `docker compose down` apenas para e remove os containers e redes da stack mantendo os volumes intactos, enquanto `docker compose down -v` remove também todos os volumes declarados, apagando permanentemente os dados armazenados.

---

## 4. Rede

- **Rede criada:** `todo-net`
- **Serviços conectados:** `app` e `db` (MySQL)
- **A porta do banco está exposta ao host?**  
  Não — a porta 3306 do banco de dados não deve ser publicada para o host por razões de segurança, permitindo que apenas os serviços internos da rede Docker (como o container do app) acessem o banco.

> **Por que o app consegue chamar o host mysql/db sem saber o IP?**  
> O Docker possui um servidor DNS embutido em suas redes customizadas que resolve automaticamente o nome do serviço ou alias da rede para o IP interno do container correspondente.

---

## 5. Docker Compose

- **Serviços:** `app` e `db`
- **Rede:** `todo-net`
- **Volume:** `todo-mysql-data`
- **Healthcheck:** Configurado no serviço `db` (`mysqladmin ping`)
- **depends_on:** `app` aguarda `db` com `condition: service_healthy`
- **Variáveis sensíveis:** Carregadas via `.env` (não versionado). Arquivo modelo entregue como `.env.example`.


---

## 6. Integração Contínua (GitHub Actions)

- **Arquivo do workflow:** `.github/workflows/ci.yml`
- **Gatilhos:** `push` e `pull_request`
- **Etapas do pipeline:**
  1. Validar o arquivo `compose.yaml` com `docker compose config`
  2. Buildar a imagem da aplicação
  3. Subir a stack inteira em segundo plano
  4. Aguardar a resposta da API e realizar smoke test via cURL (criar e consultar tarefa)
  5. Derrubar a stack e limpar volumes ao finalizar


---

## 7. Quebra proposital do CI

- **O que eu quebrei:** Alterei temporariamente o comando de inicialização `CMD` no `Dockerfile` apontando para um arquivo inexistente (`node src/indexx.js`).
- **Erro que apareceu no log:** `Error: Cannot find module '/app/src/indexx.js'` seguido de encerramento do container (`exited with code 1`).
- **Como o CI reagiu:** O step *"Aguardar a aplicação responder"* falhou após esgotar as 30 tentativas, pois o container `app` permanecia indisponível, acionando o dump de logs e abortando a execução com erro.
- **Como eu corrigi:** Voltei o caminho do `CMD` para o arquivo correto `node src/index.js`, fiz commit e push na branch do PR.
- **Link do Pull Request:** `https://github.com/Fesisp/meu-projeto-docker/pull/1`

---

## 8. Dificuldades e aprendizados

Durante a execução da atividade, os principais aprendizados envolveram a criação de Dockerfiles otimizados via *multi-stage build*, garantindo a diminuição do tamanho da imagem final e maior segurança executando como usuário não-root. Além disso, a configuração do *healthcheck* com `depends_on: condition: service_healthy` no Docker Compose se mostrou fundamental para sincronizar a inicialização da aplicação Node.js após a prontidão total do banco MySQL. Por fim, a automação do teste de integração com GitHub Actions demonstrou a importância da esteira de CI no bloqueio de alterações quebradas.

---

## 9. Checklist de autoavaliação

- [x] Dockerfile multi-stage funcionando
- [x] `.dockerignore` presente
- [x] Container não roda como root
- [x] Volume nomeado + persistência demonstrada
- [x] Rede nomeada + banco não exposto ao host
- [x] `compose.yaml` sobe tudo com um comando
- [x] `.env` no `.gitignore` e `.env.example` versionado
- [x] CI verde
- [x] PR com CI vermelho documentado
- [x] Todos os 9 prints mapeados no README