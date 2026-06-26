# Customização Visual CUPS

## Arquivos alterados

- `templates/header.tmpl`
- `templates/trailer.tmpl`
- `templates/pt_BR/header.tmpl`
- `templates/pt_BR/trailer.tmpl`
- `doc-root/cups.css`
- `doc-root/index.html`
- `doc-root/pt_BR/index.html`

## Estratégia visual

A identidade aplicada usa `Print Server ADCETEI` como nome visual principal e `Interface administrativa CUPS` como subtítulo. O CUPS permanece identificado na interface, nos links de ajuda e nas referências técnicas.

A camada visual segue uma abordagem leve:

- cabeçalho azul escuro institucional;
- links e botões em azul médio;
- fundo cinza claro;
- áreas de conteúdo brancas;
- tabelas com contraste mais suave;
- rodapé discreto;
- responsividade básica para telas menores.

Não foram adicionados frameworks, CDNs, fontes externas ou JavaScript novo.

## Cuidados com templates CUPS

Templates do CUPS podem conter variáveis, condicionais e tokens usados pelo servidor. Exemplos:

```txt
{title}
{SECTION=admin?...}
{$org.cups.sid}
{?share_printers}
{SETTINGS_ERROR?...}
```

Ao customizar, preserve estes elementos. A alteração atual manteve a navegação, os links funcionais e as condicionais de estado ativo do menu.

## O que não deve ser mexido

Não altere nesta camada visual:

- `admin.tmpl`;
- `printers.tmpl`;
- `jobs.tmpl`;
- `printer.tmpl`;
- `classes.tmpl`;
- `cupsd.conf`;
- campos hidden;
- tokens;
- links de ação;
- botões administrativos;
- formulários administrativos;
- configurações de rede ou permissão.

## Localização PT-BR

O CUPS pode servir arquivos localizados conforme idioma do ambiente ou do navegador. Por isso, os arquivos `pt_BR` de cabeçalho, rodapé e página inicial também receberam a identidade ADCETEI, preservando linguagem institucional em português.

## Atualizações do CUPS

Atualizações do pacote CUPS podem sobrescrever arquivos em:

```txt
/usr/share/cups/templates
/usr/share/cups/doc-root
```

Depois de atualizar ou reinstalar o CUPS, valide a interface e reaplique a customização com `./scripts/apply-local.sh` se necessário.
