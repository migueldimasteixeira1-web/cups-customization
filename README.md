# CUPS Customization

Customização visual da interface web nativa do CUPS para o projeto **Print Server ADCETEI**.

## O que é este projeto

Este repositório guarda uma camada visual institucional para o CUPS, normalmente acessado em:

```txt
http://localhost:631
```

A proposta é deixar a interface administrativa mais limpa, legível e alinhada ao uso interno da ADCETEI, mantendo claro que a base técnica continua sendo o CUPS.

## Objetivo da customização

- Exibir a identidade `Print Server ADCETEI`.
- Manter o subtítulo `Interface administrativa CUPS`.
- Melhorar cabeçalho, rodapé, cores, tabelas, botões e espaçamento.
- Preservar a navegação, os links, os formulários e as variáveis internas do CUPS.
- Manter a interface PT-BR quando o CUPS servir arquivos localizados em `pt_BR`.

## O que é alterado

- Templates visuais de cabeçalho e rodapé.
- Página inicial genérica e página inicial `pt_BR`.
- CSS local em `doc-root/cups.css`.
- Documentação do fluxo de customização e deploy local.
- Scripts locais de aplicação e rollback com backup.

## O que não é alterado

Este projeto não muda:

- lógica de impressão;
- filas, jobs ou impressoras configuradas;
- permissões administrativas;
- configuração de rede;
- `cupsd.conf`;
- tokens, campos hidden ou formulários administrativos;
- funcionamento do Email2Print;
- exposição do CUPS na rede.

## Estrutura principal

```txt
templates/
doc-root/
scripts/
docs/
```

Em um repositório maior, estes mesmos arquivos podem estar abaixo de `config/cups-ui/`.

## Como aplicar localmente

Execute a partir da raiz deste projeto:

```bash
./scripts/apply-local.sh
```

O script:

- valida `templates/` e `doc-root/`;
- cria backup em `/var/backups/cups-ui`;
- copia os arquivos para `/usr/share/cups/templates` e `/usr/share/cups/doc-root`;
- não usa `--delete` na aplicação inicial;
- reinicia o CUPS;
- mostra o caminho do backup e a URL de teste.

## Como testar

Abra:

```txt
http://localhost:631
http://localhost:631/printers/
http://localhost:631/jobs/
http://localhost:631/admin
```

Teste uma impressão local, ajustando o nome da impressora se necessário:

```bash
lp -d PDF /usr/share/cups/data/default-testpage.pdf
lpstat -o
```

## Como fazer rollback

Execute:

```bash
./scripts/rollback-local.sh
```

O script lista os backups disponíveis, permite escolher um deles, cria um backup de segurança do estado atual e restaura `templates` e `doc-root` com `rsync --delete`.

## Riscos e observações

- Atualizações do pacote CUPS podem sobrescrever arquivos em `/usr/share/cups`.
- A customização deve ser reaplicada após reinstalações ou atualizações que substituam a interface web.
- Revise diffs antes de alterar templates que contenham variáveis como `{title}`, `{SECTION=...}` ou `{$org.cups.sid}`.
- Esta etapa não integra o deploy real do Print Server e não altera o deploy oficial do Email2Print.
