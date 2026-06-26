# Notes

- Esta customização é visual.
- Ela não altera a lógica do CUPS.
- Ela não altera `cupsd.conf`.
- Ela não altera rede, permissões, filas, jobs ou impressoras configuradas.
- Ela não expõe o CUPS na rede.
- Ela não substitui uma integração futura com o Portal Interno.
- Ela serve como laboratório local e base para um futuro deploy no Print Server real.
- O `index.html` pode estar em PT-BR e deve permanecer em PT-BR.
- O deploy oficial do Email2Print não faz parte desta etapa.
- Atualizações do pacote CUPS podem sobrescrever `/usr/share/cups`; reaplique a customização quando necessário.
