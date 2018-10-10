-- cliente final e responsável financeiro
CREATE TABLE cs_client (
    name          varchar (100) NOT NULL,
    address       varchar (100) NOT NULL,
	number        int (5) NOT NULL,
	district      varchar (20) NOT NULL,
	geo_id        int (2) NOT NULL REFERENCES cs_geographical (geo_id),
	cep           int (8) NOT NULL,
    email         varchar (100) NOT NULL,
    dateofbirth   date NOT NULL,
    rg            int (10) NOT NULL,
    cpf           int (11) PRIMARY KEY,
    photo         bytea NOT NULL,
    cellphone     int (11) NOT NULL,
    gender        int NOT NULL REFERENCES cs_gender (gender_id),
	status        int (1)DEFAULT '1' -- 1 ACTIVE or 2 INATIVE
);

-- paciente, podendo ou não ser o cliente final
CREATE TABLE cs_patient (
    name          varchar (100) NOT NULL,
    address       varchar (100) NOT NULL,
	number        int (5) NOT NULL,
	district      varchar (20) NOT NULL,
	geo_id        int (2) NOT NULL REFERENCES cs_geographical (geo_id),
	cep           int (8) NOT NULL,
    details       text (500), 
    dateofbirth   date NOT NULL,
    rg            int (10) NOT NULL,
    cpf           int (11) PRIMARY KEY,
	cpfClient     int (11) REFERENCES cs_client (cpf),
    photo         bytea NOT NULL,
    gender        int NOT NULL REFERENCES cs_gender (gender_id),
    kinship       varchar (10)
);

-- prestador de serviço
CREATE TABLE cs_service_provider (
	name          varchar (100) NOT NULL,
    dateofbirth   date NOT NULL,
    account       int (10),
	digit         int (3),
	agency        int (6),
	bank          int (4) REFERENCES cs_bank_srv_prov (bank),
	address       varchar (100) NOT NULL,
	number        int (5) NOT NULL,
	district      varchar (20) NOT NULL,
	geo_id        int (2) NOT NULL REFERENCES cs_geographical (geo_id),
	cep           int (8) NOT NULL,
    rg            int (10) NOT NULL,
    cpf           int (11) PRIMARY KEY,
    cep           int (8) NOT NULL,
    email         varchar (100) NOT NULL,
    photo         bytea NOT NULL,
	gender        int NOT NULL REFERENCES cs_gender (gender_id),
	status        int (1) DEFAULT '3' -- 1 ACTIVE or 2 INATIVE or 3 PENDING  
);

-- serviços fornecidos pelos prestadores de serviço
CREATE TABLE cs_srv_prov_exec (
	srv_prov_exec_id int (100) PRIMARY KEY DEFAULT NEXTVAL (sr_prov_id_sequence),
	offer_id         int (10) REFERENCES cs_offer (offer_id),
	cpf              int (11) REFERENCES cs_service_provider (cpf),
	info01           int (20), -- registro nos órgãos responsáveis
	info02           bytea NOT NULL, -- certificado para cuidadores de idosos, auxiliar e técnico de enfermagem
	info03           bytea NOT NULL, -- diploma ou declaração de conclusão para enfermeiro e fisioterapeuta
	info04           bytea NOT NULL, -- currículo
	valueHour        decimal (6,2) NOT NULL, -- valor hora para atendimento
    valueSession     decimal (6,2) NOT NULL  -- valor da sessão: fisioterapeutas, psicólogos, fonoaudiólogos
);

-- especialidades/serviços ofertados
CREATE TABLE cs_offer (
	offer_id    int (2) PRIMARY KEY DEFAULT NEXTVAL (offer_id_sequence),
	offer_desc  varchar (20)     
);

-- detalhes dos bancos para realizar pagamentos
CREATE TABLE cs_bank_srv_prov (
	bank         int (4) PRIMARY KEY,
	description  varchar (20) NOT NULL
);

-- gênero
CREATE TABLE cs_gender (
	gender_id    int (2) PRIMARY KEY DEFAULT NEXTVAL (gender_id_sequence),
	gender_desc  varchar (20)
);

-- estados e cidades
CREATE TABLE cs_geographical (
	geo_id   int (2) PRIMARY KEY DEFAULT NEXTVAL (geo_id_sequence),
	geo_uf   varchar (2),
	geo_city varchar (20)
);

-- logins - clientes
CREATE TABLE cs_login_cli (
    login         varchar (60) NOT NULL,
    password      varchar (10) NOT NULL,
	cpf           int (11) REFERENCES cs_client (cpf)
);

-- logins - prestador de serviço
CREATE TABLE cs_login_srv_prov (
    login         varchar (60) NOT NULL,
    password      varchar (10) NOT NULL,
	cpf           int (11) REFERENCES cs_service_provider (cpf)
);

-- agendamentos realizados. Se o prestador de serviço não tem agendamento, retorna para ser escolhido pelo cliente
CREATE TABLE cs_schedule (
	schedule_id       int (200) PRIMARY KEY DEFAULT NEXTVAL (schedule_id_sequence),
	cpf_srv_prov      int (11) REFERENCES cs_service_provider (cpf),
	cpf_cli           int (11) REFERENCES cs_client (cpf),
	cpf_pat           int (11) REFERENCES cs_patient (cpf),
	start_date        date, -- data e hora
	end_date          date, -- data e hora
	sessions          int (4) -- quantas sessões agendadas
	service           int (100) REFERENCES cs_srv_prov_exec (srv_prov_exec_id)
);

-- faturamento: NF emitida pela CS ao prestador de serviço, NF para o cliente com custo 0, NF do prestador vs cliente não é responsabilidade CS
CREATE TABLE cs_invoice (
	invoice_id          int (200) PRIMARY KEY DEFAULT NEXTVAL (invoice_id_sequence),
	schedule_id         int (200) REFERENCES cs_schedule (schedule_id),
	total_value         decimal (6,2), -- valor_total do serviço prestado ao cliente
	pis                 decimal (6,2), -- impostos a serem considerados na NF do valor bruto CS
	cofins              decimal (6,2),
	irpj                decimal (6,2),
	csll                decimal (6,2),
	prev                decimal (6,2),
	iss                 decimal (6,2),
	value_cs_total      decimal (6,2), -- 20% do total_value + valor base para calcular os impostos
	value_cs_profit     decimal (6,2), -- lucro abatendo os impostos CS
	value_pay_srv_prov  decimal (6,2) -- 80% do total_value = valor a ser pago ao prestador de serviço
);

-- alíquotas
CREATE TABLE cs_aliquot (
	aliquot_id      int (200) PRIMARY KEY DEFAULT NEXTVAL (aliquot_id_sequence),
	aliquot_type    decimal (6,2),
	aliquot_value   decimal (6,2),
	aliquot_state   decimal (6,2)
);