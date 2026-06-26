# Deploy Local

Este passo a passo aplica a customização visual no CUPS local. Ele não altera `cupsd.conf`, rede, permissões ou filas de impressão.

## Pré-requisitos

- CUPS instalado localmente.
- Acesso administrativo via `sudo` ou execução como `root`.
- `rsync` disponível.

## Aplicar

Na raiz deste projeto:

```bash
./scripts/apply-local.sh
```

O script cria backup em `/var/backups/cups-ui`, copia `templates/` e `doc-root/` para os caminhos nativos do CUPS e reinicia o serviço.

## Validar interface

Abra:

```txt
http://localhost:631
http://localhost:631/printers/
http://localhost:631/jobs/
http://localhost:631/admin
```

Confirme:

- aparece `Print Server ADCETEI`;
- aparece `Interface administrativa CUPS`;
- menus, formulários e links administrativos continuam funcionando;
- a interface não foi exposta na rede.

## Testar impressão

Use uma impressora local existente. Exemplo com impressora chamada `PDF`:

```bash
lp -d PDF /usr/share/cups/data/default-testpage.pdf
lpstat -o
```

Se a impressora tiver outro nome, liste as filas com:

```bash
lpstat -p
```

## Rollback

Execute:

```bash
./scripts/rollback-local.sh
```

Escolha um backup listado pelo script. Antes de restaurar, o rollback cria um backup de segurança do estado atual.

## Caminhos usados

Origem no projeto:

```txt
templates/
doc-root/
```

Destino no CUPS:

```txt
/usr/share/cups/templates
/usr/share/cups/doc-root
```

Backups:

```txt
/var/backups/cups-ui
```
