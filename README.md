
# Scripts de Instalação do NetBox para Ubuntu 24.04.2

## Visão Geral

Este repositório contém scripts para a instalação automática do NetBox versão 4.x no Ubuntu 24.04.2. O NetBox é uma ferramenta de código aberto para gerenciamento de endereços IP (IPAM) e gerenciamento de infraestrutura de data centers (DCIM), projetada para ajudar a gerenciar e documentar redes de computadores.

Os scripts fornecidos aqui têm como objetivo simplificar o processo de configuração, automatizando a instalação e configuração do NetBox e suas dependências em um sistema Ubuntu 24.04.2 novo.

## Recursos

- **Instalação Automatizada**: Instala o NetBox v4.x com todas as dependências necessárias.
- **Compatibilidade com Ubuntu 24.04.2**: Desenvolvido especificamente para o Ubuntu 24.04.2 LTS.
- **Configuração Fácil**: Inclui scripts para configurar o NetBox, PostgreSQL e outros serviços.
- **Pronto para Produção**: Segue as melhores práticas para uma implementação segura e estável do NetBox.

## Pré-requisitos

- Uma instalação limpa do Ubuntu 24.04.2 LTS.
- Privilégios de root ou sudo.
- Acesso à internet para baixar pacotes e dependências.
- Familiaridade básica com operações no terminal Linux.

## Instalação

1. **Clonar o Repositório**:
   ```bash
   git clone https://github.com/seu-usuario/instalacao-netbox.git
   cd instalacao-netbox
   ```

2. **Executar o Script de Instalação**:
   ```bash
   sudo bash install-netbox.sh
   ```

   O script irá:
   - Instalar pacotes necessários (por exemplo, PostgreSQL, Python, Nginx).
   - Configurar um ambiente virtual Python para o NetBox.
   - Configurar o NetBox com padrões seguros.
   - Iniciar os serviços necessários (por exemplo, Gunicorn, Nginx).

3. **Acessar o NetBox**:
   - Abra seu navegador e acesse `http://<ip-do-servidor>/`.
   - Faça login usando as credenciais padrão (configuradas durante a instalação).

## Configuração

- **Banco de Dados**: O script configura o PostgreSQL como backend de banco de dados.
- **Servidor Web**: O Nginx é configurado como proxy reverso.
- **Personalização**: Modifique o arquivo `configuration.py` no diretório do NetBox para configurações personalizadas (por exemplo, hosts permitidos, chave secreta).

## Uso

Após a instalação, você pode gerenciar o NetBox por meio de sua interface web ou ferramentas de linha de comando. Consulte a [documentação oficial do NetBox](https://docs.netbox.dev/) para instruções detalhadas de uso.

## Contribuição

Contribuições são bem-vindas! Por favor, envie um pull request ou abra uma issue para sugestões de melhorias ou correções de bugs.

## Licença

Este projeto está licenciado sob a Licença MIT. Veja o arquivo [LICENSE](LICENSE) para detalhes.

## Aviso Legal

Estes scripts são fornecidos como estão. Sempre revise os scripts antes de executá-los em sistemas de produção e certifique-se de ter backups.

