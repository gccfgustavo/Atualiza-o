 --- 2017---
 
 --0.40
 
 

 
--SET client_min_messages TO ERROR;
 
 SELECT docwin.inserealterahelp('A','C','ACDLGSLDC','
   Determina   se  ser� ou n�o exibido o
   di�logo:  <b>"Selecionar  os  documentos 
   que ser�o impressos automaticamente?"</b>
 
   Caso  n�o  marcado ser� considerada a 
   resposta <b>N�O</b> para o di�logo acima.','Sele��o de documentos');
 
 CREATE OR REPLACE FUNCTION docwin.log_tb(_campo text)
   RETURNS void AS
  $BODY$ 
 DECLARE
     ri RECORD;
     idreg BIGINT;
     campo_novo TEXT;
     campo_antigo text;
 BEGIN
     if ( TG_OP = 'INSERT') then	
 	insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 
 			   (idreg   ,ri.column_name         ,quote_ident(TG_relname)      , ''            ,'Ato inserido'       ,now()            ,user);
     else 
 	 if ( TG_OP = 'DELETE') then
 	        insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 
 				 (idreg    ,'ato deletado'      	,quote_ident(TG_relname), 'apagado'     ,'apagado'  		,now()        		,user);
 	 end if;	
     end if;			
     FOR ri IN
         SELECT  column_name
         FROM information_schema.columns
         WHERE
             table_schema = quote_ident(TG_TABLE_SCHEMA)
         AND table_name = quote_ident(TG_TABLE_NAME)
         ORDER BY ordinal_position
     LOOP
 	if ( TG_OP = 'UPDATE') then		
 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_antigo using old;
 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_novo using NEW;
 		if campo_novo <> campo_antigo then
 			insert into docwin.p_log_modificacoes_tb (id      , campo_modificado, tabela                , valor_anterior  , valor_posterior, data_modificacao, usuario) values 
 				        (idreg  ,ri.column_name   ,quote_ident(TG_relname), campo_antigo    ,campo_novo      ,now()      ,user);
                 end if;
         end if;       
     END LOOP;
     RETURN;
 END;
  $BODY$ 
   LANGUAGE plpgsql VOLATILE
   COST 100;
 ALTER FUNCTION docwin.log_tb(text)
   OWNER TO postgres;
 GRANT EXECUTE ON FUNCTION docwin.log_tb(text) TO postgres;
 GRANT EXECUTE ON FUNCTION docwin.log_tb(text) TO public;
 GRANT EXECUTE ON FUNCTION docwin.log_tb(text) TO docwin_owner;
 GRANT EXECUTE ON FUNCTION docwin.log_tb(text) TO escreventes;
 GRANT EXECUTE ON FUNCTION docwin.log_tb(text) TO supervisores;
 
 CREATE OR REPLACE FUNCTION docwin.log_p_poderes_tb()
   RETURNS trigger AS
  $BODY$ 
 DECLARE
     ri RECORD;
     campo_novo TEXT;
     campo_antigo text;
 BEGIN
 
 if (quote_ident(TG_relname) = 'p_poderes_campos_variaveis_tb') then
     if ( TG_OP = 'INSERT') then	
 	insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 
 			   (new.po_key   ,'Campo vari�vel inserido'         ,quote_ident(TG_relname)      , ''            ,(SELECT cv_key::text || '-' || cv_titulo FROM docwin.p_campos_variaveis_tb WHERE p_campos_variaveis_tb.cv_key = new.cv_key
 )       ,now()            ,user);
     else 
 	 if ( TG_OP = 'DELETE') then
 	        insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 
 				 (old.po_key    ,'Campo vari�vel deletado'      	,quote_ident(TG_relname), (SELECT cv_key::text || '-' || cv_titulo 
 								FROM docwin.p_campos_variaveis_tb WHERE p_campos_variaveis_tb.cv_key = old.cv_key)     ,''  		,now()        		,user);
 	 end if;	
     end if;	
 elseif (quote_ident(TG_relname) = 'p_poderes_exigencias_tb') then
     if ( TG_OP = 'INSERT') then	
 	insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 
 			   (new.po_key   ,'Exig�ncia inserida'         ,quote_ident(TG_relname)      , ''            ,new.pe_exigencia       ,now()            ,user);
     else 
 	 if ( TG_OP = 'DELETE') then
 	        insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 
 				 (old.po_key    ,'Exig�ncia deletada'      	,quote_ident(TG_relname), old.pe_exigencia    ,''  		,now()        		,user);
 	 end if;	
     end if;	
 else
    if ( TG_OP = 'INSERT') then	
 	insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 
 			   (new.po_key   ,'Poder inserido'         ,quote_ident(TG_relname)      , ''            ,new.po_titulo       ,now()            ,user);
     else 
 	 if ( TG_OP = 'DELETE') then
 	        insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 
 				 (old.po_key    ,'Poder deletado'      	,quote_ident(TG_relname), old.po_titulo     ,''  		,now()        		,user);
 	 end if;	
     end if;	
 end if;
 		
     FOR ri IN
         SELECT  column_name
         FROM information_schema.columns
         WHERE
             table_schema = quote_ident(TG_TABLE_SCHEMA)
         AND table_name = quote_ident(TG_TABLE_NAME)
         ORDER BY ordinal_position
     LOOP
 	if ( TG_OP = 'UPDATE') then		
 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_antigo using old;
 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_novo using NEW;
 		if campo_novo <> campo_antigo then
 			insert into docwin.p_log_modificacoes_tb (id      , campo_modificado, tabela                , valor_anterior  , valor_posterior, data_modificacao, usuario) values 
 				        (old.po_key  ,ri.column_name   ,quote_ident(TG_relname), campo_antigo    ,campo_novo      ,now()      ,user);
                 end if;
         end if;       
     END LOOP;
     RETURN NEW;
 END;
  $BODY$ 
   LANGUAGE plpgsql VOLATILE
   COST 100;
 ALTER FUNCTION docwin.log_p_poderes_tb()
   OWNER TO postgres;
 GRANT EXECUTE ON FUNCTION docwin.log_p_poderes_tb() TO postgres;
 GRANT EXECUTE ON FUNCTION docwin.log_p_poderes_tb() TO public;
 GRANT EXECUTE ON FUNCTION docwin.log_p_poderes_tb() TO docwin_owner;
 GRANT EXECUTE ON FUNCTION docwin.log_p_poderes_tb() TO escreventes;
 GRANT EXECUTE ON FUNCTION docwin.log_p_poderes_tb() TO supervisores;
 
 CREATE OR REPLACE FUNCTION docwin.log_p_ato_tb()
   RETURNS trigger AS
  $BODY$ 
 DECLARE
     ri RECORD;
     campo_novo TEXT;
     campo_antigo text;
 BEGIN
 	
  if (quote_ident(TG_relname) = 'p_participantes_tb') then
 	if ( TG_OP = 'INSERT') then	
 		insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 
 				   (new.at_key   ,'Participante inserido'      ,quote_ident(TG_relname), ''            ,(SELECT CASE  WHEN new.pa_tipo = 'F' THEN 
 								(SELECT 'CPF n� ' || lpad(ph_cpf::text, 11,'0') FROM docwin.pessoa_fisica_historico_tb WHERE new.pa_id = ph_id) ELSE 
 								(SELECT 'CNPJ n� ' || lpad(pjh_cnpj::text,15,'0') FROM docwin.pessoa_juridica_historico_tb WHERE new.pa_id = pjh_id) END)      ,now()            ,user);
 	else 
 		if ( TG_OP = 'DELETE') then
 			insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 
 				 (old.at_key    ,'Participante exclu�do'      	,quote_ident(TG_relname), (SELECT CASE  WHEN old.pa_tipo = 'F' THEN 
 								(SELECT 'CPF n� ' || lpad(ph_cpf::text, 11,'0') FROM docwin.pessoa_fisica_historico_tb WHERE old.pa_id = ph_id) ELSE 
 								(SELECT 'CNPJ n� ' || lpad(pjh_cnpj::text,15,'0') FROM docwin.pessoa_juridica_historico_tb WHERE old.pa_id = pjh_id) END)  ,''		,now()        		,user);
 		end if;	
 	end if;
 
     FOR ri IN
         SELECT  column_name
         FROM information_schema.columns
         WHERE
             table_schema = quote_ident(TG_TABLE_SCHEMA)
         AND table_name = quote_ident(TG_TABLE_NAME)
         ORDER BY ordinal_position
     LOOP
 	if ( TG_OP = 'UPDATE') then		
 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_antigo using old;
 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_novo using NEW;
 		if campo_novo <> campo_antigo then
 			insert into docwin.p_log_modificacoes_tb (id      , campo_modificado, tabela                , valor_anterior  , valor_posterior, data_modificacao, usuario) values 
 				        (old.at_key  ,ri.column_name || ' do participante ' ||  (SELECT CASE  WHEN old.pa_tipo = 'F' THEN 
 								(SELECT 'CPF n� ' || lpad(ph_cpf::text, 11,'0') FROM docwin.pessoa_fisica_historico_tb WHERE old.pa_id = ph_id) ELSE 
 								(SELECT 'CNPJ n� ' || lpad(pjh_cnpj::text,15,'0') FROM docwin.pessoa_juridica_historico_tb WHERE old.pa_id = pjh_id) END)   || ' do ato ' || (SELECT 'Livro ' || at_livronome::text || '-' || (CASE WHEN at_livronumero < 0 THEN '*' ELSE at_livronumero::text END) 
 			|| ', Pag. ini. '  || (CASE WHEN at_folhanumero < 0 THEN '*' ELSE at_folhanumero::text END) 
 			|| ' e Pag. final. '  || (CASE WHEN at_folhanumerofinal < 0 THEN '*' ELSE at_folhanumerofinal::text END)
 				FROM docwin.p_atos_tb WHERE at_key=old.at_key)   ,quote_ident(TG_relname), campo_antigo    ,campo_novo      ,now()      ,user);
                 end if;
         end if;       
     END LOOP;
     RETURN NEW;
 
 elseif (quote_ident(TG_relname) = 'p_participantes_representantes_tb') then
 	if ( TG_OP = 'INSERT') then	
 		insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 
 				   (new.at_key   ,'Representante inserido'      ,quote_ident(TG_relname), ''            ,((SELECT CASE  WHEN new.re_tipo = 'F' THEN 
 								(SELECT 'Representante ' || ph_nome FROM docwin.pessoa_fisica_historico_tb WHERE new.re_id = ph_id) ELSE 
 								(SELECT 'Representante ' || pjh_razao FROM docwin.pessoa_juridica_historico_tb WHERE new.re_id = pjh_id) END) || ' do participante ' || (SELECT CASE  WHEN pa_tipo = 'F' THEN 
 								(SELECT 'CPF n� ' || lpad(ph_cpf::text, 11,'0') FROM docwin.pessoa_fisica_historico_tb WHERE new.pa_id = ph_id) ELSE 
 								(SELECT 'CNPJ n� ' || lpad(pjh_cnpj::text,15,'0') FROM docwin.pessoa_juridica_historico_tb WHERE new.pa_id = pjh_id) END 
 								 FROM docwin.p_participantes_tb WHERE p_participantes_tb.at_key = new.at_key AND p_participantes_tb.pa_id = new.pa_id))      ,now()            ,user);
 	else 
 		if ( TG_OP = 'DELETE') then
 			insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 
 				 (old.at_key    ,'Representante exclu�do'      	,quote_ident(TG_relname), ((SELECT CASE  WHEN old.re_tipo = 'F' THEN 
 								(SELECT 'Representante ' || ph_nome FROM docwin.pessoa_fisica_historico_tb WHERE old.re_id = ph_id) ELSE 
 								(SELECT 'Representante ' || pjh_razao FROM docwin.pessoa_juridica_historico_tb WHERE old.re_id = pjh_id) END) || ' do participante ' || (SELECT CASE  WHEN pa_tipo = 'F' THEN 
 								(SELECT 'CPF n� ' || lpad(ph_cpf::text, 11,'0') FROM docwin.pessoa_fisica_historico_tb WHERE old.pa_id = ph_id) ELSE 
 								(SELECT 'CNPJ n� ' || lpad(pjh_cnpj::text,15,'0') FROM docwin.pessoa_juridica_historico_tb WHERE old.pa_id = pjh_id) END 
 								 FROM docwin.p_participantes_tb WHERE p_participantes_tb.at_key = old.at_key AND p_participantes_tb.pa_id = old.pa_id))  ,''		,now()        		,user);
 		end if;	
 	end if;
 elseif (quote_ident(TG_relname) = 'p_participantes_rogo_tb') then
 	if ( TG_OP = 'INSERT') then	
 		insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 
 				   (new.at_key   ,'Rogo inserido'      ,quote_ident(TG_relname), ''            ,((SELECT 'Rogo ' || ph_nome FROM docwin.pessoa_fisica_historico_tb WHERE new.pf_id = ph_id)
 								|| ' do participante ' || (SELECT CASE  WHEN pa_tipo = 'F' THEN 
 								(SELECT 'CPF n� ' || lpad(ph_cpf::text, 11,'0') FROM docwin.pessoa_fisica_historico_tb WHERE new.pa_id = ph_id) ELSE 
 								(SELECT 'CNPJ n� ' || lpad(pjh_cnpj::text,15,'0') FROM docwin.pessoa_juridica_historico_tb WHERE new.pa_id = pjh_id) END 
 								 FROM docwin.p_participantes_tb WHERE p_participantes_tb.at_key = new.at_key AND p_participantes_tb.pa_id = new.pa_id))      ,now()            ,user);
 	else 
 		if ( TG_OP = 'DELETE') then
 			insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 
 				 (old.at_key    ,'Rogo exclu�do'      	,quote_ident(TG_relname), ((SELECT 'Rogo ' || ph_nome FROM docwin.pessoa_fisica_historico_tb WHERE old.re_id = ph_id)  
 								|| ' do participante ' || (SELECT CASE  WHEN pa_tipo = 'F' THEN 
 								(SELECT 'CPF n� ' || lpad(ph_cpf::text, 11,'0') FROM docwin.pessoa_fisica_historico_tb WHERE old.pa_id = ph_id) ELSE 
 								(SELECT 'CNPJ n� ' || lpad(pjh_cnpj::text,15,'0') FROM docwin.pessoa_juridica_historico_tb WHERE old.pa_id = pjh_id) END 
 								 FROM docwin.p_participantes_tb WHERE p_participantes_tb.at_key = old.at_key AND p_participantes_tb.pa_id = old.pa_id))  ,''		,now()        		,user);
 		end if;	
 	end if;
 elseif (quote_ident(TG_relname) = 'p_participantes_testestemunhas_tb') then
 	if ( TG_OP = 'INSERT') then	
 		insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 
 				   (new.at_key   ,'Testemunha inserida'      ,quote_ident(TG_relname), ''            ,((SELECT 'Testemunha ' || ph_nome FROM docwin.pessoa_fisica_historico_tb WHERE new.pf_key = ph_id)
 								|| ' do participante ' || (SELECT CASE  WHEN pa_tipo = 'F' THEN 
 								(SELECT 'CPF n� ' || lpad(ph_cpf::text, 11,'0') FROM docwin.pessoa_fisica_historico_tb WHERE new.pa_id = ph_id) ELSE 
 								(SELECT 'CNPJ n� ' || lpad(pjh_cnpj::text,15,'0') FROM docwin.pessoa_juridica_historico_tb WHERE new.pa_id = pjh_id) END 
 								 FROM docwin.p_participantes_tb WHERE p_participantes_tb.at_key = new.at_key AND p_participantes_tb.pa_id = new.pa_id))      ,now()            ,user);
 	else 
 		if ( TG_OP = 'DELETE') then
 			insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 
 				 (old.at_key    ,'Testemunha exclu�da'      	,quote_ident(TG_relname), ((SELECT 'Testemunha ' || ph_nome FROM docwin.pessoa_fisica_historico_tb WHERE old.pf_key = ph_id)  
 								|| ' do participante ' || (SELECT CASE  WHEN pa_tipo = 'F' THEN 
 								(SELECT 'CPF n� ' || lpad(ph_cpf::text, 11,'0') FROM docwin.pessoa_fisica_historico_tb WHERE old.pa_id = ph_id) ELSE 
 								(SELECT 'CNPJ n� ' || lpad(pjh_cnpj::text,15,'0') FROM docwin.pessoa_juridica_historico_tb WHERE old.pa_id = pjh_id) END 
 								 FROM docwin.p_participantes_tb WHERE p_participantes_tb.at_key = old.at_key AND p_participantes_tb.pa_id = old.pa_id))  ,''		,now()        		,user);
 		end if;	
 	end if;
 elseif (quote_ident(TG_relname) = 'p_atos_poderes_tb') then
 	if ( TG_OP = 'INSERT') then	
 		insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 
 				   (new.at_key   ,'Poder inserido'      ,quote_ident(TG_relname), ''            ,(SELECT 'Poder ' || po_titulo FROM docwin.p_poderes_tb WHERE new.po_key = po_key)
 								      ,now()            ,user);
 	else 
 		if ( TG_OP = 'DELETE') then
 			insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 
 				 (old.at_key    ,'Poder exclu�do'      	,quote_ident(TG_relname), (SELECT 'Poder ' || po_titulo FROM docwin.p_poderes_tb WHERE old.po_key = po_key)  
 								  ,''		,now()        		,user);
 		end if;	
 	end if;
 
     FOR ri IN
         SELECT  column_name
         FROM information_schema.columns
         WHERE
             table_schema = quote_ident(TG_TABLE_SCHEMA)
         AND table_name = quote_ident(TG_TABLE_NAME)
         ORDER BY ordinal_position
     LOOP
 	if ( TG_OP = 'UPDATE') then		
 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_antigo using old;
 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_novo using NEW;
 		if campo_novo <> campo_antigo then
 			insert into docwin.p_log_modificacoes_tb (id      , campo_modificado, tabela                , valor_anterior  , valor_posterior, data_modificacao, usuario) values 
 				        (old.at_key  ,ri.column_name || ' ' || (SELECT ' do poder ' || po_titulo FROM docwin.p_poderes_tb WHERE old.po_key = po_key)   || ' do ato ' || (SELECT 'Livro ' || at_livronome::text || '-' || (CASE WHEN at_livronumero < 0 THEN '*' ELSE at_livronumero::text END) 
 			|| ', Pag. ini. '  || (CASE WHEN at_folhanumero < 0 THEN '*' ELSE at_folhanumero::text END) 
 			|| ' e Pag. final. '  || (CASE WHEN at_folhanumerofinal < 0 THEN '*' ELSE at_folhanumerofinal::text END)
 				FROM docwin.p_atos_tb WHERE at_key=old.at_key)   ,quote_ident(TG_relname), campo_antigo    ,campo_novo      ,now()      ,user);
                 end if;
         end if;       
     END LOOP;
     RETURN NEW;
 
 elseif (quote_ident(TG_relname) = 'p_testetmunhas_ato') then
 	if ( TG_OP = 'INSERT') then	
 		insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 
 				   (new.at_key   ,'Testemunha do ato inserida'      ,quote_ident(TG_relname), ''            ,(SELECT 'Testemunha ' || ph_nome FROM docwin.pessoa_fisica_historico_tb WHERE new.pf_id = ph_id)      ,now()            ,user);
 	else 
 		if ( TG_OP = 'DELETE') then
 			insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 
 				 (old.at_key    ,'Testemunha do ato exclu�da'      	,quote_ident(TG_relname), (SELECT 'Testemunha ' || ph_nome FROM docwin.pessoa_fisica_historico_tb WHERE old.pf_id = ph_id)  ,''		,now()        		,user);
 		end if;	
 	end if;
 
 elseif (quote_ident(TG_relname) = 'p_vadi_tb') then
 	if ( TG_OP = 'INSERT') then	
 		insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 
 				   (new.va_link   ,'Var. Adicional do ato inserida'      ,quote_ident(TG_relname), ''            ,(SELECT 'Var. Adicional ' || ad_tit FROM docwin.p_adic_tb  WHERE new.va_codi = ad_cod)      ,now()            ,user);
 	else 
 		if ( TG_OP = 'DELETE') then
 			insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 
 				 (old.va_link    ,'Var. Adicional do ato exclu�da'      	,quote_ident(TG_relname), (SELECT 'Var. Adicional ' || ad_tit FROM  docwin.p_adic_tb WHERE old.va_codi = ad_cod)  ,''		,now()        		,user);
 		end if;	
 	end if;
 
     FOR ri IN
         SELECT  column_name
         FROM information_schema.columns
         WHERE
             table_schema = quote_ident(TG_TABLE_SCHEMA)
         AND table_name = quote_ident(TG_TABLE_NAME)
         ORDER BY ordinal_position
     LOOP
 	if ( TG_OP = 'UPDATE') then		
 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_antigo using old;
 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_novo using NEW;
 		if campo_novo <> campo_antigo then
 			insert into docwin.p_log_modificacoes_tb (id      , campo_modificado, tabela                , valor_anterior  , valor_posterior, data_modificacao, usuario) values 
 				        (old.va_link  ,ri.column_name || ' ' || (SELECT 'Var. Adicional ' || ad_tit FROM  docwin.p_adic_tb WHERE old.va_codi = ad_cod) || ' do ato ' || (SELECT 'Livro ' || at_livronome::text || '-' || (CASE WHEN at_livronumero < 0 THEN '*' ELSE at_livronumero::text END) 
 			|| ', Pag. ini. '  || (CASE WHEN at_folhanumero < 0 THEN '*' ELSE at_folhanumero::text END) 
 			|| ' e Pag. final. '  || (CASE WHEN at_folhanumerofinal < 0 THEN '*' ELSE at_folhanumerofinal::text END)
 				FROM docwin.p_atos_tb WHERE at_key=old.va_link)   ,quote_ident(TG_relname), campo_antigo    ,campo_novo      ,now()      ,user);
                 end if;
         end if;       
     END LOOP;
     RETURN NEW;
 
 
 elseif (quote_ident(TG_relname) = 'p_atos_cobrancas_tb') then
 	if ( TG_OP = 'INSERT') then	
 		insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 
 				   (new.at_key   ,'Cobran�a do ato inserida'      ,quote_ident(TG_relname), ''            ,(SELECT 'Cobran�a ' || descricao FROM docwin.u_ato_padronizado_tb  WHERE new.co_key = id)      ,now()            ,user);
 	else 
 		if ( TG_OP = 'DELETE') then
 			insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 
 				 (old.at_key    ,'Cobran�a do ato exclu�da'      	,quote_ident(TG_relname), (SELECT 'Cobran�a ' || descricao FROM  docwin.u_ato_padronizado_tb WHERE old.co_key = id) || CASE WHEN old.ac_ordem > 0 THEN ' vinculada a OS ' || old.ac_ordem ELSE '' END  ,''		,now()        		,user);
 		end if;	
 	end if;
 
     FOR ri IN
         SELECT  column_name
         FROM information_schema.columns
         WHERE
             table_schema = quote_ident(TG_TABLE_SCHEMA)
         AND table_name = quote_ident(TG_TABLE_NAME)
         ORDER BY ordinal_position
     LOOP
 	if ( TG_OP = 'UPDATE') then		
 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_antigo using old;
 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_novo using NEW;
 		if campo_novo <> campo_antigo then
 			insert into docwin.p_log_modificacoes_tb (id      , campo_modificado, tabela                , valor_anterior  , valor_posterior, data_modificacao, usuario) values 
 				        (old.at_key  ,ri.column_name || ' ' || (SELECT 'Cobran�a ' || descricao FROM  docwin.u_ato_padronizado_tb WHERE old.co_key = id) || ' do ato ' || (SELECT 'Livro ' || at_livronome::text || '-' || (CASE WHEN at_livronumero < 0 THEN '*' ELSE at_livronumero::text END) 
 			|| ', Pag. ini. '  || (CASE WHEN at_folhanumero < 0 THEN '*' ELSE at_folhanumero::text END) 
 			|| ' e Pag. final. '  || (CASE WHEN at_folhanumerofinal < 0 THEN '*' ELSE at_folhanumerofinal::text END)
 				FROM docwin.p_atos_tb WHERE at_key=old.at_key)   ,quote_ident(TG_relname), campo_antigo    ,campo_novo      ,now()      ,user);
                 end if;
         end if;       
     END LOOP;
     RETURN NEW;
 
 
 
 elseif (quote_ident(TG_relname) = 'p_atos_assentamentos_tb') then
 	if ( TG_OP = 'INSERT') then	
 		insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 
 				   (new.va_link   ,'Assentamento do ato inserida'      ,quote_ident(TG_relname), ''            ,'Assentamento ' || new.aa_titulo     ,now()            ,user);
 	else 
 		if ( TG_OP = 'DELETE') then
 			insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 
 				 (old.va_link    ,'Assentamento do ato exclu�da'      	,quote_ident(TG_relname),'Assentamento ' || old.aa_titulo,''		,now()        		,user);
 		end if;	
 	end if;
 
     FOR ri IN
         SELECT  column_name
         FROM information_schema.columns
         WHERE
             table_schema = quote_ident(TG_TABLE_SCHEMA)
         AND table_name = quote_ident(TG_TABLE_NAME)
         ORDER BY ordinal_position
     LOOP
 	if ( TG_OP = 'UPDATE') then		
 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_antigo using old;
 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_novo using NEW;
 		if campo_novo <> campo_antigo then
 			insert into docwin.p_log_modificacoes_tb (id      , campo_modificado, tabela                , valor_anterior  , valor_posterior, data_modificacao, usuario) values 
 				        (old.va_link  ,ri.column_name || ' ' || 'Assentamento ' || old.aa_titulo || ' do ato ' || (SELECT 'Livro ' || at_livronome::text || '-' || (CASE WHEN at_livronumero < 0 THEN '*' ELSE at_livronumero::text END) 
 			|| ', Pag. ini. '  || (CASE WHEN at_folhanumero < 0 THEN '*' ELSE at_folhanumero::text END) 
 			|| ' e Pag. final. '  || (CASE WHEN at_folhanumerofinal < 0 THEN '*' ELSE at_folhanumerofinal::text END)
 				FROM docwin.p_atos_tb WHERE at_key=old.at_key)   ,quote_ident(TG_relname), campo_antigo    ,campo_novo      ,now()      ,user);
                 end if;
         end if;       
     END LOOP;
     RETURN NEW;
 
 
 else
 	if ( TG_OP = 'INSERT') then	
 		insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 
 				   (new.at_key ,  'Ato inserido (' || new.at_key::text ||')' ,quote_ident(TG_relname)      , ''            ,'Ato inserido'       ,now()            ,user);
 	else 
 		 if ( TG_OP = 'DELETE') then
 			insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 
 					 (old.at_key    ,'Ato exclu�do (' || new.at_key::text ||')', quote_ident(TG_relname), 'Livro ' || old.at_livronome::text || '-' || (CASE WHEN old.at_livronumero < 0 THEN '*' ELSE old.at_livronumero::text END) 
 			|| ', Pag. ini. '  || (CASE WHEN old.at_folhanumero < 0 THEN '*' ELSE old.at_folhanumero::text END) 
 			|| ' e Pag. final. '  || (CASE WHEN old.at_folhanumerofinal < 0 THEN '*' ELSE old.at_folhanumerofinal::text END),''  		,now()        		,user);
 		 end if;	
     end if;
 end if;
     FOR ri IN
         SELECT  column_name
         FROM information_schema.columns
         WHERE
             table_schema = quote_ident(TG_TABLE_SCHEMA)
         AND table_name = quote_ident(TG_TABLE_NAME)
         ORDER BY ordinal_position
     LOOP
 	if ( TG_OP = 'UPDATE') then		
 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_antigo using old;
 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_novo using NEW;
 		if campo_novo <> campo_antigo then
 			insert into docwin.p_log_modificacoes_tb (id      , campo_modificado, tabela                , valor_anterior  , valor_posterior, data_modificacao, usuario) values 
 				        (old.at_key  ,ri.column_name || ' do ato ' || (SELECT 'Livro ' || at_livronome::text || '-' || (CASE WHEN at_livronumero < 0 THEN '*' ELSE at_livronumero::text END) 
 			|| ', Pag. ini. '  || (CASE WHEN at_folhanumero < 0 THEN '*' ELSE at_folhanumero::text END) 
 			|| ' e Pag. final. '  || (CASE WHEN at_folhanumerofinal < 0 THEN '*' ELSE at_folhanumerofinal::text END)
 				FROM docwin.p_atos_tb WHERE at_key=old.at_key)   ,quote_ident(TG_relname), campo_antigo    ,campo_novo      ,now()      ,user);
                 end if;
         end if;       
     END LOOP;
     RETURN NEW;
 END;
  $BODY$ 
   LANGUAGE plpgsql VOLATILE
   COST 100;
 ALTER FUNCTION docwin.log_p_ato_tb()
   OWNER TO postgres;
 GRANT EXECUTE ON FUNCTION docwin.log_p_ato_tb() TO postgres;
 GRANT EXECUTE ON FUNCTION docwin.log_p_ato_tb() TO public;
 GRANT EXECUTE ON FUNCTION docwin.log_p_ato_tb() TO docwin_owner;
 GRANT EXECUTE ON FUNCTION docwin.log_p_ato_tb() TO escreventes;
 GRANT EXECUTE ON FUNCTION docwin.log_p_ato_tb() TO supervisores;
 
 CREATE OR REPLACE FUNCTION docwin.log_p_comissoes_tb()
   RETURNS trigger AS
  $BODY$ 
 DECLARE
     ri RECORD;
     campo_novo TEXT;
     campo_antigo text;
 BEGIN
     if ( TG_OP = 'INSERT') then	
 	insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 
 			   (new.user_id   ,'Comiss�o inserida'         ,quote_ident(TG_relname)      , ''            ,(SELECT user_nome FROM docwin.aux_user_tb WHERE user_id = new.user_id) 
 															|| ' valor ' ||  ' ato ' || new.co_ato::text || '%, subscri��o ' || new.co_subscricao::text || '%'
       ,now()            ,user);
     else 
 	 if ( TG_OP = 'DELETE') then
 	        insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 
 				 (old.user_id    ,'Comiss�o deletada'      	,quote_ident(TG_relname),(SELECT user_nome FROM docwin.aux_user_tb WHERE user_id = old.user_id) 
 															|| ' valor ' ||  ' ato ' || old.co_ato::text || '%, subscri��o ' || old.co_subscricao::text || '%',''  		,now()        		,user);
 	 end if;	
     end if;			
     FOR ri IN
         SELECT  column_name
         FROM information_schema.columns
         WHERE
             table_schema = quote_ident(TG_TABLE_SCHEMA)
         AND table_name = quote_ident(TG_TABLE_NAME)
         ORDER BY ordinal_position
     LOOP
 	if ( TG_OP = 'UPDATE') then		
 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_antigo using old;
 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_novo using NEW;
 		if campo_novo <> campo_antigo then
 			insert into docwin.p_log_modificacoes_tb (id      , campo_modificado, tabela                , valor_anterior  , valor_posterior, data_modificacao, usuario) values 
 				        (old.user_id  ,ri.column_name   ,quote_ident(TG_relname), campo_antigo    ,campo_novo      ,now()      ,user);
                 end if;
         end if;       
     END LOOP;
     RETURN NEW;
 END;
  $BODY$ 
   LANGUAGE plpgsql VOLATILE
   COST 100;
 ALTER FUNCTION docwin.log_p_comissoes_tb()
   OWNER TO postgres;
 GRANT EXECUTE ON FUNCTION docwin.log_p_comissoes_tb() TO postgres;
 GRANT EXECUTE ON FUNCTION docwin.log_p_comissoes_tb() TO public;
 GRANT EXECUTE ON FUNCTION docwin.log_p_comissoes_tb() TO docwin_owner;
 GRANT EXECUTE ON FUNCTION docwin.log_p_comissoes_tb() TO escreventes;
 GRANT EXECUTE ON FUNCTION docwin.log_p_comissoes_tb() TO supervisores;
 
 
 CREATE OR REPLACE FUNCTION docwin.log_p_justificativas_tb()
   RETURNS trigger AS
  $BODY$ 
 DECLARE
     ri RECORD;
     campo_novo TEXT;
     campo_antigo text;
 BEGIN
     if ( TG_OP = 'INSERT') then	
 	insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 
 			   (new.ju_key   ,'Justificativa inserida'                ,quote_ident(TG_relname)      , ''            ,new.ju_titulo       ,now()            ,user);
     else 
 	 if ( TG_OP = 'DELETE') then
 	        insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 
 				 (old.ju_key    ,'Justificativa deletada'      	,quote_ident(TG_relname), old.ju_titulo     ,''  		,now()        		,user);
 	 end if;	
     end if;			
     FOR ri IN
         SELECT  column_name
         FROM information_schema.columns
         WHERE
             table_schema = quote_ident(TG_TABLE_SCHEMA)
         AND table_name = quote_ident(TG_TABLE_NAME)
         ORDER BY ordinal_position
     LOOP
 	if ( TG_OP = 'UPDATE') then		
 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_antigo using old;
 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_novo using NEW;
 		if campo_novo <> campo_antigo then
 			insert into docwin.p_log_modificacoes_tb (id      , campo_modificado, tabela                , valor_anterior  , valor_posterior, data_modificacao, usuario) values 
 				        (old.ju_key  ,ri.column_name   ,quote_ident(TG_relname), campo_antigo    ,campo_novo      ,now()      ,user);
                 end if;
         end if;       
     END LOOP;
     RETURN NEW;
 END;
  $BODY$ 
   LANGUAGE plpgsql VOLATILE
   COST 100;
 ALTER FUNCTION docwin.log_p_justificativas_tb()
   OWNER TO postgres;
 GRANT EXECUTE ON FUNCTION docwin.log_p_justificativas_tb() TO postgres;
 GRANT EXECUTE ON FUNCTION docwin.log_p_justificativas_tb() TO public;
 GRANT EXECUTE ON FUNCTION docwin.log_p_justificativas_tb() TO docwin_owner;
 GRANT EXECUTE ON FUNCTION docwin.log_p_justificativas_tb() TO escreventes;
 GRANT EXECUTE ON FUNCTION docwin.log_p_justificativas_tb() TO supervisores;
 
 CREATE OR REPLACE FUNCTION docwin.log_p_justificativas_tb()
   RETURNS trigger AS
  $BODY$ 
 DECLARE
     ri RECORD;
     campo_novo TEXT;
     campo_antigo text;
 BEGIN
     if ( TG_OP = 'INSERT') then	
 	insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 
 			   (new.ju_key   ,'Justificativa inserida'                ,quote_ident(TG_relname)      , ''            ,new.ju_titulo       ,now()            ,user);
     else 
 	 if ( TG_OP = 'DELETE') then
 	        insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 
 				 (old.ju_key    ,'Justificativa deletada'      	,quote_ident(TG_relname), old.ju_titulo     ,''  		,now()        		,user);
 	 end if;	
     end if;			
     FOR ri IN
         SELECT  column_name
         FROM information_schema.columns
         WHERE
             table_schema = quote_ident(TG_TABLE_SCHEMA)
         AND table_name = quote_ident(TG_TABLE_NAME)
         ORDER BY ordinal_position
     LOOP
 	if ( TG_OP = 'UPDATE') then		
 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_antigo using old;
 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_novo using NEW;
 		if campo_novo <> campo_antigo then
 			insert into docwin.p_log_modificacoes_tb (id      , campo_modificado, tabela                , valor_anterior  , valor_posterior, data_modificacao, usuario) values 
 				        (old.ju_key  ,ri.column_name   ,quote_ident(TG_relname), campo_antigo    ,campo_novo      ,now()      ,user);
                 end if;
         end if;       
     END LOOP;
     RETURN NEW;
 END;
  $BODY$ 
   LANGUAGE plpgsql VOLATILE
   COST 100;
 ALTER FUNCTION docwin.log_p_justificativas_tb()
   OWNER TO postgres;
 GRANT EXECUTE ON FUNCTION docwin.log_p_justificativas_tb() TO postgres;
 GRANT EXECUTE ON FUNCTION docwin.log_p_justificativas_tb() TO public;
 GRANT EXECUTE ON FUNCTION docwin.log_p_justificativas_tb() TO docwin_owner;
 GRANT EXECUTE ON FUNCTION docwin.log_p_justificativas_tb() TO escreventes;
 GRANT EXECUTE ON FUNCTION docwin.log_p_justificativas_tb() TO supervisores;
 
 CREATE OR REPLACE FUNCTION docwin.log_p_restricoes_tb()
   RETURNS trigger AS
  $BODY$ 
 DECLARE
     ri RECORD;
     campo_novo TEXT;
     campo_antigo text;
 BEGIN
     if ( TG_OP = 'INSERT') then	
 	insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 
 			   (new.re_key   ,'Restri��o inserida'         ,quote_ident(TG_relname)      , ''            , (SELECT CASE WHEN new.re_tipo = 1 THEN 'CPF N� ' || lpad(new.re_documento, 11 ,'0')::text ELSE 'CNPJ N� ' || lpad(new.re_documento, 11 ,'0') END)      ,now()            ,user);
     else 
 	 if ( TG_OP = 'DELETE') then
 	        insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 
 				 (old.re_key    ,'Restri��o exclu�da'      	,quote_ident(TG_relname), (SELECT CASE WHEN old.re_tipo = 1 THEN 'CPF N� ' || lpad(old.re_documento, 11 ,'0')::text ELSE 'CNPJ N� ' || lpad(old.re_documento, 11 ,'0') END)     ,''  		,now()        		,user);
 	 end if;	
     end if;			
     FOR ri IN
         SELECT  column_name
         FROM information_schema.columns
         WHERE
             table_schema = quote_ident(TG_TABLE_SCHEMA)
         AND table_name = quote_ident(TG_TABLE_NAME)
         ORDER BY ordinal_position
     LOOP
 	if ( TG_OP = 'UPDATE') then		
 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_antigo using old;
 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_novo using NEW;
 		if campo_novo <> campo_antigo then
 			insert into docwin.p_log_modificacoes_tb (id      , campo_modificado, tabela                , valor_anterior  , valor_posterior, data_modificacao, usuario) values 
 				        (old.re_key  ,ri.column_name   ,quote_ident(TG_relname), campo_antigo    ,campo_novo      ,now()      ,user);
                 end if;
         end if;       
     END LOOP;
     RETURN NEW;
 END;
  $BODY$ 
   LANGUAGE plpgsql VOLATILE
   COST 100;
 ALTER FUNCTION docwin.log_p_restricoes_tb()
   OWNER TO postgres;
 GRANT EXECUTE ON FUNCTION docwin.log_p_restricoes_tb() TO postgres;
 GRANT EXECUTE ON FUNCTION docwin.log_p_restricoes_tb() TO public;
 GRANT EXECUTE ON FUNCTION docwin.log_p_restricoes_tb() TO docwin_owner;
 GRANT EXECUTE ON FUNCTION docwin.log_p_restricoes_tb() TO escreventes;
 GRANT EXECUTE ON FUNCTION docwin.log_p_restricoes_tb() TO supervisores;
 
 CREATE OR REPLACE FUNCTION docwin.log_pessoa_fisica_historico_tb()
   RETURNS trigger AS
  $BODY$ 
 DECLARE
     ri RECORD;
     campo_novo TEXT;
     campo_antigo text;
 BEGIN
     if ( TG_OP = 'INSERT') then	
 	insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 
 			   (new.ph_id   ,'Pessoa f�sica inclu�da'         ,quote_ident(TG_relname)      , ''            ,new.ph_nome || ' CPF n� ' || lpad(new.ph_cpf::text, 11, '0')        ,now()            ,user);
     else 
 	 if ( TG_OP = 'DELETE') then
 	        insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 
 				 (old.ph_id    ,'Pessoa f�sica excuida'      	,quote_ident(TG_relname), old.ph_nome || ' CPF n� ' || lpad(old.ph_cpf::text, 11, '0')      ,''  		,now()        		,user);
 	 end if;	
     end if;			
     FOR ri IN
         SELECT  column_name
         FROM information_schema.columns
         WHERE
             table_schema = quote_ident(TG_TABLE_SCHEMA)
         AND table_name = quote_ident(TG_TABLE_NAME)
         ORDER BY ordinal_position
     LOOP
 	if ( TG_OP = 'UPDATE') then		
 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_antigo using old;
 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_novo using NEW;
 		if campo_novo <> campo_antigo then
 			insert into docwin.p_log_modificacoes_tb (id      , campo_modificado, tabela                , valor_anterior  , valor_posterior, data_modificacao, usuario) values 
 				        ((SELECT at_key FROM docwin.p_participantes_tb WHERE pa_tipo = 'F' AND pa_id=old.ph_id  ), ri.column_name || ' de ' || old.ph_nome   ,quote_ident(TG_relname), campo_antigo    ,campo_novo      ,now()      ,user);
                
 		end if;
         end if;       
     END LOOP;
     RETURN NEW;
 END;
  $BODY$ 
   LANGUAGE plpgsql VOLATILE
   COST 100;
 ALTER FUNCTION docwin.log_pessoa_fisica_historico_tb()
   OWNER TO postgres;
 GRANT EXECUTE ON FUNCTION docwin.log_pessoa_fisica_historico_tb() TO postgres;
 GRANT EXECUTE ON FUNCTION docwin.log_pessoa_fisica_historico_tb() TO public;
 GRANT EXECUTE ON FUNCTION docwin.log_pessoa_fisica_historico_tb() TO docwin_owner;
 GRANT EXECUTE ON FUNCTION docwin.log_pessoa_fisica_historico_tb() TO escreventes;
 GRANT EXECUTE ON FUNCTION docwin.log_pessoa_fisica_historico_tb() TO supervisores;
 
 CREATE OR REPLACE FUNCTION docwin.log_pessoa_juridica_historico_tb()
   RETURNS trigger AS
  $BODY$ 
 DECLARE
     ri RECORD;
     campo_novo TEXT;
     campo_antigo text;
 BEGIN
     if ( TG_OP = 'INSERT') then	
 	insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 
 			   (new.pjh_id   ,'Pessoa jur�dica inclu�da'         ,quote_ident(TG_relname)      , ''            ,new.pjh_razao || ' CNPJ n� ' || lpad(new.pjh_cnpj::text, 14, '0')       ,now()            ,user);
     else 
 	 if ( TG_OP = 'DELETE') then
 	        insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 
 				 (old.pjh_id    ,'Pessoa jur�dica exclu�da'      	,quote_ident(TG_relname), old.pjh_razao || ' CNPJ n� ' || lpad(old.pjh_cnpj::text, 14, '0')     ,''  		,now()        		,user);
 	 end if;	
     end if;			
     FOR ri IN
         SELECT  column_name
         FROM information_schema.columns
         WHERE
             table_schema = quote_ident(TG_TABLE_SCHEMA)
         AND table_name = quote_ident(TG_TABLE_NAME)
         ORDER BY ordinal_position
     LOOP
 	if ( TG_OP = 'UPDATE') then		
 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_antigo using old;
 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_novo using NEW;
 		if campo_novo <> campo_antigo then
 			insert into docwin.p_log_modificacoes_tb (id      , campo_modificado, tabela                , valor_anterior  , valor_posterior, data_modificacao, usuario) values 
 				        ((SELECT at_key FROM docwin.p_participantes_tb WHERE pa_tipo = 'J' AND pa_id=old.pjh_id),ri.column_name   ,quote_ident(TG_relname), campo_antigo    ,campo_novo      ,now()      ,user);
                 end if;
         end if;       
     END LOOP;
     RETURN NEW;
 END;
  $BODY$ 
   LANGUAGE plpgsql VOLATILE
   COST 100;
 ALTER FUNCTION docwin.log_pessoa_juridica_historico_tb()
   OWNER TO postgres;
 GRANT EXECUTE ON FUNCTION docwin.log_pessoa_juridica_historico_tb() TO postgres;
 GRANT EXECUTE ON FUNCTION docwin.log_pessoa_juridica_historico_tb() TO public;
 GRANT EXECUTE ON FUNCTION docwin.log_pessoa_juridica_historico_tb() TO docwin_owner;
 GRANT EXECUTE ON FUNCTION docwin.log_pessoa_juridica_historico_tb() TO escreventes;
 GRANT EXECUTE ON FUNCTION docwin.log_pessoa_juridica_historico_tb() TO supervisores;
 
 CREATE OR REPLACE FUNCTION docwin.update_function_triger_minuta_poder_campo()
   RETURNS trigger AS
  $BODY$ 
 DECLARE
 	    ri RECORD;
 	    campo_novo TEXT;
 	    campo_antigo text;
 BEGIN
 
 UPDATE docwin.aux_func_tb SET fu_tit = NEW.cv_titulo, fu_dsc = 'CAMPO ADICIONAL. ' || NEW.cv_descricao WHERE fu_mod = 'P' AND fu_cod >= 1000 AND fu_cont = NEW.cv_key::text;
 
 FOR ri IN
 SELECT  column_name
 FROM information_schema.columns
 WHERE
     table_schema = quote_ident(TG_TABLE_SCHEMA)
 AND table_name = quote_ident(TG_TABLE_NAME)
 ORDER BY ordinal_position
 LOOP
 if ( TG_OP = 'UPDATE') then		
 	Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_antigo using old;
 	Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_novo using NEW;
 	if campo_novo <> campo_antigo then
 		insert into docwin.p_log_modificacoes_tb (id      , campo_modificado, tabela                , valor_anterior  , valor_posterior, data_modificacao, usuario) values 
 				(old.cv_key  ,ri.column_name   ,quote_ident(TG_relname), campo_antigo    ,campo_novo      ,now()      ,user);
 	end if;
 end if;       
 END LOOP;
 RETURN NEW;
 END;
  $BODY$ 
   LANGUAGE plpgsql VOLATILE
   COST 100;
 ALTER FUNCTION docwin.update_function_triger_minuta_poder_campo()
   OWNER TO postgres;
 
 CREATE OR REPLACE FUNCTION docwin.insert_function_triger_minuta_poder_campo()
   RETURNS trigger AS
  $BODY$ 
     BEGIN
 	INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho,fu_mask, fu_cont, fu_altera)
 	VALUES ((SELECT CASE WHEN MAX(fu_cod) IS NULL THEN 1000 ELSE MAX(fu_cod) + 1 END FROM docwin.aux_func_tb WHERE fu_mod = 'P' AND fu_cod >= 1000), 
 		'P', NEW.cv_titulo, 'CAMPO ADICIONAL. ' || NEW.cv_descricao, 0, 'F', null,null,NEW.cv_key, null);
         RETURN NEW;
     END;
    $BODY$ 
   LANGUAGE plpgsql VOLATILE
   COST 100;
 ALTER FUNCTION docwin.insert_function_triger_minuta_poder_campo()
   OWNER TO postgres;
 
 
 CREATE OR REPLACE FUNCTION docwin.criatabelasmodulop() RETURNS void as
  $$ 
 BEGIN 
 
 	IF NOT EXISTS(SELECT column_name FROM information_schema.columns WHERE table_schema='docwin' AND table_name='aux_para_tb' AND column_name='pa_codcolegionotarial') THEN
 		ALTER TABLE docwin.aux_para_tb ADD COLUMN pa_codcolegionotarial text;
 	END IF;
 	
 	IF NOT EXISTS(SELECT table_name FROM information_schema.tables 
                    WHERE table_schema='docwin' AND table_name='aux_livro_numeracao_tb') THEN
 		CREATE TABLE IF NOT EXISTS docwin.aux_livro_numeracao_tb
 		(   
 		  nome text,
 		  nrolivroatual integer,
 		  regporfolha smallint DEFAULT 2,
 		  inipag integer,
 		  inifv "char",
 		  curpag integer,
 		  curfv "char",
 		  fimpag integer,
 		  fimfv "char",
 		  ultimotermo integer,
 		  id integer NOT NULL,  
 		  acervo_id integer,  
 		  CONSTRAINT aux_livro_numeracao_tb_pkey PRIMARY KEY (id, acervo_id)
 		)WITH (OIDS=FALSE);
 		ALTER TABLE docwin.aux_livro_numeracao_tb OWNER TO docwin_owner;
 		GRANT ALL ON TABLE docwin.aux_livro_numeracao_tb TO supervisores;
 		GRANT ALL ON TABLE docwin.aux_livro_numeracao_tb TO escreventes;
 
 		
 		INSERT INTO docwin.aux_livro_numeracao_tb(nome, nrolivroatual, regporfolha, inipag, inifv, curpag, curfv, fimpag, fimfv, ultimotermo, id, acervo_id) SELECT lv_nome, lv_nrolivroatual, lv_regporfolha, lv_inipag, lv_inifv, lv_curpag, lv_curfv, lv_fimpag, lv_fimfv, lv_ultimotermo, lv_id, 1  FROM docwin.aux_livros_tb;
 
 		ALTER TABLE docwin.aux_livros_tb  DROP COLUMN lv_nrolivroatual;
 		ALTER TABLE docwin.aux_livros_tb  DROP COLUMN lv_regporfolha;
 		ALTER TABLE docwin.aux_livros_tb  DROP COLUMN lv_inipag;
 		ALTER TABLE docwin.aux_livros_tb  DROP COLUMN lv_inifv;
 		ALTER TABLE docwin.aux_livros_tb  DROP COLUMN lv_curpag;
 		ALTER TABLE docwin.aux_livros_tb  DROP COLUMN lv_curfv;
 		ALTER TABLE docwin.aux_livros_tb  DROP COLUMN lv_fimpag;
 		ALTER TABLE docwin.aux_livros_tb  DROP COLUMN lv_fimfv;
 		ALTER TABLE docwin.aux_livros_tb  DROP COLUMN lv_ultimotermo;	
 	END IF;
 
 
 	CREATE TABLE IF NOT EXISTS docwin.p_campos_variaveis_tb
 	(
 	cv_key serial NOT NULL,
 	cv_descricao text NOT NULL,
 	cv_tipo smallint NOT NULL,
 	cv_conteudoprevio text,
 	cv_mascara text,
 	cv_titulo text,
 	CONSTRAINT p_campos_variaveis_tb_pkey PRIMARY KEY (cv_key)
 	)
 	WITH (
 	OIDS=FALSE
 	);
 	ALTER TABLE docwin.p_campos_variaveis_tb
 	OWNER TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_campos_variaveis_tb TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_campos_variaveis_tb TO escreventes;
 	GRANT ALL ON TABLE docwin.p_campos_variaveis_tb TO supervisores;
 
 	IF NOT EXISTS(SELECT trigger_name FROM information_schema.triggers where trigger_name='InsertFuncao' AND trigger_schema='docwin') THEN
 		CREATE TRIGGER "InsertFuncao"
 		AFTER INSERT
 		ON docwin.p_campos_variaveis_tb
 		FOR EACH ROW
 		EXECUTE PROCEDURE docwin.insert_function_triger_minuta_poder_campo();
 	END IF;	
 
 	IF NOT EXISTS(SELECT trigger_name FROM information_schema.triggers where trigger_name='UpdateFuncao' AND trigger_schema='docwin') THEN
 		CREATE TRIGGER "UpdateFuncao"
 		AFTER UPDATE
 		ON docwin.p_campos_variaveis_tb
 		FOR EACH ROW
 		EXECUTE PROCEDURE docwin.update_function_triger_minuta_poder_campo();
 	END IF;
 	
 	CREATE TABLE IF NOT EXISTS docwin.p_poderes_tb
 	(
 	po_key serial NOT NULL,
 	po_tipo_ato smallint NOT NULL,
 	po_cod smallint NOT NULL,
 	po_titulo text NOT NULL,
 	po_minuta text NOT NULL,
 	CONSTRAINT p_poderes_tb_pkey PRIMARY KEY (po_key)
 	)
 	WITH (
 	OIDS=FALSE
 	);
 	ALTER TABLE docwin.p_poderes_tb
 	OWNER TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_poderes_tb TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_poderes_tb TO escreventes;
 	GRANT ALL ON TABLE docwin.p_poderes_tb TO supervisores;
 
 	IF NOT EXISTS (SELECT trigger_name FROM information_schema.triggers where trigger_name='tgr_p_poderes_tb' AND trigger_schema='docwin') THEN
 		CREATE TRIGGER tgr_p_poderes_tb
 		AFTER UPDATE OR DELETE
 		ON docwin.p_poderes_tb
 		FOR EACH ROW
 		EXECUTE PROCEDURE docwin.log_p_poderes_tb();
 	END IF;	
 
 	CREATE TABLE IF NOT EXISTS docwin.p_atos_tb
 	(
 	at_key bigserial NOT NULL,
 	at_tipoato smallint NOT NULL,
 	at_naturezaescritura smallint,
 	at_substabelecimento smallint,
 	at_lavrouato integer,
 	at_subscreveuato integer,
 	at_lavroucertidao integer,
 	at_subscreveucertidao integer,
 	at_formavalidade smallint,
 	at_validadedata date,
 	at_validadeano smallint,
 	at_validademes smallint,
 	at_validadedia smallint,
 	at_diligencia boolean,
 	at_localdiligencia text,
 	at_observacoes text,
 	at_livronome text,
 	at_livronumero smallint,
 	at_folhanumero smallint,
 	at_folhanumerofinal smallint,
 	at_acervo integer,
 	at_livronome2 character varying(5),
 	at_livronumero2 smallint,
 	at_folhanumero2 smallint,
 	at_folhanumerofinal2 smallint,
 	at_serventiaato2 text,
 	at_status integer NOT NULL,
 	at_dataato timestamp without time zone,
 	at_valor numeric,
 	at_reservapoder boolean,
 	at_nomelocal text,
 	at_nomelavrouato text,
 	at_arquivopasta text,
 	at_arquivonumero numeric,
 	at_endereco text,
 	at_numeroendereco smallint,
 	at_complemento text,
 	at_bairro text,
 	at_cidade text,
 	at_uf character varying(2),
 	at_pais text,
 	at_cep text,
 	at_permitiasubstabelecimento "char",
 	at_permitiarevogacao "char",
 	at_locallavratura smallint,
 	at_datalavraturaato2 timestamp without time zone,
 	at_livroid integer,
 	at_livro2complemento text,
 	at_livrocomplemento text,
 	at_folhacomplemento text,
 	at_folha2complemento text,
 	at_subtipoato smallint,
 	at_qtdefilhosmaiores smallint,
 	at_qtdefilhosmenores smallint,
 	at_responsavelfilhosmenores smallint,
 	at_dataregistroreferencia timestamp without time zone,
 	at_itcmd numeric,
 	CONSTRAINT p_atos_tb_pkey PRIMARY KEY (at_key),
 	CONSTRAINT p_atos_tb_user_la FOREIGN KEY (at_lavrouato)
 	REFERENCES docwin.aux_user_tb (user_id) MATCH SIMPLE
 	ON UPDATE NO ACTION ON DELETE NO ACTION,
 	CONSTRAINT p_atos_tb_user_lc FOREIGN KEY (at_lavroucertidao)
 	REFERENCES docwin.aux_user_tb (user_id) MATCH SIMPLE
 	ON UPDATE NO ACTION ON DELETE NO ACTION,
 	CONSTRAINT p_atos_tb_user_sa FOREIGN KEY (at_subscreveuato)
 	REFERENCES docwin.aux_user_tb (user_id) MATCH SIMPLE
 	ON UPDATE NO ACTION ON DELETE NO ACTION,
 	CONSTRAINT p_atos_tb_user_sc FOREIGN KEY (at_subscreveucertidao)
 	REFERENCES docwin.aux_user_tb (user_id) MATCH SIMPLE
 	ON UPDATE NO ACTION ON DELETE NO ACTION
 	)
 	WITH (
 	OIDS=FALSE
 	);
 	ALTER TABLE docwin.p_atos_tb
 	OWNER TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_atos_tb TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_atos_tb TO escreventes;
 	GRANT ALL ON TABLE docwin.p_atos_tb TO supervisores;
 
 
 	CREATE TABLE IF NOT EXISTS docwin.p_participantes_tb
 	(
 	at_key serial NOT NULL,
 	pa_id integer NOT NULL,
 	pa_tipo "char" NOT NULL,
 	pa_participacao smallint NOT NULL,
 	pa_resultadoconsulta boolean NOT NULL,
 	pa_codigohash text NOT NULL,
 	pa_resultadoconsultacj boolean,
 	pa_codigohashcj text,
 	pa_conjugeparticipa boolean NOT NULL,
 	pa_codigoconjuge smallint,
 	CONSTRAINT p_participantes_tb_pkey PRIMARY KEY (at_key, pa_id, pa_tipo),
 	CONSTRAINT p_participantes_tb_p_atos_tb FOREIGN KEY (at_key)
 	REFERENCES docwin.p_atos_tb (at_key) MATCH SIMPLE
 	ON UPDATE NO ACTION ON DELETE CASCADE
 	)
 	WITH (
 	OIDS=FALSE
 	);
 	ALTER TABLE docwin.p_participantes_tb
 	OWNER TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_participantes_tb TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_participantes_tb TO escreventes;
 	GRANT ALL ON TABLE docwin.p_participantes_tb TO supervisores;
 
 	IF NOT EXISTS (SELECT trigger_name FROM information_schema.triggers where trigger_name='tgr_p_participantes_tb' AND trigger_schema='docwin') THEN
 		CREATE TRIGGER tgr_p_participantes_tb
 		AFTER INSERT OR UPDATE OR DELETE
 		ON docwin.p_participantes_tb
 		FOR EACH ROW
 		EXECUTE PROCEDURE docwin.log_p_ato_tb();
 	END IF;
 	
 	CREATE TABLE IF NOT EXISTS docwin.p_adic_tb
 	(
 	ad_cod integer NOT NULL,
 	ad_tit text,
 	ad_mask text,
 	ad_tel smallint,
 	ad_del boolean,
 	ad_cont text,
 	ad_tipo smallint,
 	ad_obr boolean DEFAULT false,
 	CONSTRAINT p_adic_tb_pkey PRIMARY KEY (ad_cod)
 	)
 	WITH (
 	OIDS=FALSE
 	);
 	ALTER TABLE docwin.p_adic_tb
 	OWNER TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_adic_tb TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_adic_tb TO escreventes;
 	GRANT ALL ON TABLE docwin.p_adic_tb TO supervisores;
 
 	
 	CREATE OR REPLACE RULE log_nadic_delete AS
 	ON DELETE TO docwin.p_adic_tb DO  INSERT INTO docwin.aux_log_tb (log_user_login, log_datetime, log_oper, log_tab, log_info, log_user_ip)
 	VALUES ("current_user"(), now(), 'Exclus�o de Var. Adicional'::text, 'Notas'::text, 'Vari�vel: '::text || old.ad_tit, inet_client_addr());
 
 	CREATE OR REPLACE RULE log_nadic_insert AS
 	ON INSERT TO docwin.p_adic_tb DO  INSERT INTO docwin.aux_log_tb (log_user_login, log_datetime, log_oper, log_tab, log_info, log_user_ip)
 	VALUES ("current_user"(), now(), 'Inclus�o de Var. Adicional'::text, 'Notas'::text, 'Vari�vel: '::text || new.ad_tit, inet_client_addr());
 
 	
 	CREATE OR REPLACE RULE log_nadic_update AS
 	ON UPDATE TO docwin.p_adic_tb DO  INSERT INTO docwin.aux_log_tb (log_user_login, log_datetime, log_oper, log_tab, log_info, log_user_ip)
 	VALUES ("current_user"(), now(), 'Altera��o de Var. Adicional'::text, 'Notas'::text, 'Vari�vel: '::text || new.ad_tit, inet_client_addr());
 
 	
 	CREATE TABLE IF NOT EXISTS docwin.p_atos_assentamentos_tb
 	(
 	aa_key serial NOT NULL,
 	at_key bigint NOT NULL,
 	aa_titulo text NOT NULL,
 	aa_texto text NOT NULL,
 	aa_data timestamp without time zone,
 	CONSTRAINT p_atos_assentamentos_tb_pkey PRIMARY KEY (aa_key),
 	CONSTRAINT p_atos_assentamentos_tb_atos_tb_fkey FOREIGN KEY (at_key)
 	REFERENCES docwin.p_atos_tb (at_key) MATCH SIMPLE
 	ON UPDATE CASCADE ON DELETE CASCADE
 	)
 	WITH (
 	OIDS=FALSE
 	);
 	ALTER TABLE docwin.p_atos_assentamentos_tb
 	OWNER TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_atos_assentamentos_tb TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_atos_assentamentos_tb TO escreventes;
 	GRANT ALL ON TABLE docwin.p_atos_assentamentos_tb TO supervisores;
 
 	
 	IF NOT EXISTS (SELECT trigger_name FROM information_schema.triggers where trigger_name='tgr_p_atos_assentamentos_tb' AND trigger_schema='docwin') THEN
 		CREATE TRIGGER tgr_p_atos_assentamentos_tb
 		AFTER INSERT OR UPDATE OF aa_titulo, aa_texto OR DELETE
 		ON docwin.p_atos_assentamentos_tb
 		FOR EACH ROW
 		EXECUTE PROCEDURE docwin.log_p_ato_tb();
 	END IF;
 
 	CREATE TABLE IF NOT EXISTS docwin.p_atos_poderes_tb
 	(
 	at_key integer NOT NULL,
 	po_key integer NOT NULL,
 	ap_texto text NOT NULL,
 	CONSTRAINT p_ato_poderes_pkey PRIMARY KEY (at_key, po_key),
 	CONSTRAINT p_atopoderes_tb_p_poderes_tb FOREIGN KEY (po_key)
 	REFERENCES docwin.p_poderes_tb (po_key) MATCH SIMPLE
 	ON UPDATE NO ACTION ON DELETE NO ACTION,
 	CONSTRAINT p_atos_poderes_tb_p_atos_tb_fkey FOREIGN KEY (at_key)
 	REFERENCES docwin.p_atos_tb (at_key) MATCH SIMPLE
 	ON UPDATE CASCADE ON DELETE CASCADE
 	)
 	WITH (
 	OIDS=FALSE
 	);
 	ALTER TABLE docwin.p_atos_poderes_tb
 	OWNER TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_atos_poderes_tb TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_atos_poderes_tb TO escreventes;
 	GRANT ALL ON TABLE docwin.p_atos_poderes_tb TO supervisores;
 
 	IF NOT EXISTS (SELECT trigger_name FROM information_schema.triggers where trigger_name='tgr_p_atos_poderes_tb' AND trigger_schema='docwin') THEN
 		CREATE TRIGGER tgr_p_atos_poderes_tb
 		AFTER INSERT OR UPDATE OR DELETE
 		ON docwin.p_atos_poderes_tb
 		FOR EACH ROW
 		EXECUTE PROCEDURE docwin.log_p_ato_tb();
 	END IF;
 		
 	CREATE TABLE IF NOT EXISTS docwin.p_atos_cobrancas_tb
 	(
 	ac_key bigserial NOT NULL,
 	at_key bigint NOT NULL,
 	co_key integer NOT NULL,
 	ac_guia text,
 	ac_ordem integer,
 	ac_data timestamp without time zone,
 	ac_valorbase double precision,
 	CONSTRAINT p_atos_cobrancas_tb_pkey PRIMARY KEY (ac_key),
 	CONSTRAINT p_atos_cobrancas_tb_atos_tb_fkey FOREIGN KEY (at_key)
 	REFERENCES docwin.p_atos_tb (at_key) MATCH SIMPLE
 	ON UPDATE CASCADE ON DELETE CASCADE,
 	CONSTRAINT p_atos_cobrancas_tb_ordem_servico_tb FOREIGN KEY (ac_ordem)
 	REFERENCES docwin.u_ordem_servico_tb (id) MATCH SIMPLE
 	ON UPDATE NO ACTION ON DELETE CASCADE
 	)
 	WITH (
 	OIDS=FALSE
 	);
 	ALTER TABLE docwin.p_atos_cobrancas_tb
 	OWNER TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_atos_cobrancas_tb TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_atos_cobrancas_tb TO escreventes;
 	GRANT ALL ON TABLE docwin.p_atos_cobrancas_tb TO supervisores;
 
 	IF NOT EXISTS (SELECT trigger_name FROM information_schema.triggers where trigger_name='tgr_p_atos_cobrancas_tb' AND trigger_schema='docwin') THEN
 		CREATE TRIGGER tgr_p_atos_cobrancas_tb
 		AFTER INSERT OR UPDATE OR DELETE
 		ON docwin.p_atos_cobrancas_tb
 		FOR EACH ROW
 		EXECUTE PROCEDURE docwin.log_p_ato_tb();
 	END IF;
 
 	CREATE TABLE IF NOT EXISTS docwin.p_atos_poderes_campos_variaveis_tb
 	(
 	at_key integer NOT NULL,
 	po_key integer NOT NULL,
 	cv_key integer NOT NULL,
 	valor text NOT NULL,
 	CONSTRAINT p_atos_poderes_campos_variaveis_tb_pkey PRIMARY KEY (at_key, po_key, cv_key),
 	CONSTRAINT p_atos_poderes_campos_variaveis_tb_atos_poderes_tb_fkey FOREIGN KEY (at_key, po_key)
 	REFERENCES docwin.p_atos_poderes_tb (at_key, po_key) MATCH SIMPLE
 	ON UPDATE CASCADE ON DELETE CASCADE,
 	CONSTRAINT p_atos_poderes_campos_variaveis_tb_campos_tb_fkey FOREIGN KEY (cv_key)
 	REFERENCES docwin.p_campos_variaveis_tb (cv_key) MATCH SIMPLE
 	ON UPDATE CASCADE ON DELETE CASCADE
 	)
 	WITH (
 	OIDS=FALSE
 	);
 	ALTER TABLE docwin.p_atos_poderes_campos_variaveis_tb
 	OWNER TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_atos_poderes_campos_variaveis_tb TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_atos_poderes_campos_variaveis_tb TO escreventes;
 	GRANT ALL ON TABLE docwin.p_atos_poderes_campos_variaveis_tb TO supervisores;
 
 	IF NOT EXISTS (SELECT trigger_name FROM information_schema.triggers where trigger_name='tgr_p_atos_poderes_campos_variaveis_tb' AND trigger_schema='docwin') THEN
 		CREATE TRIGGER tgr_p_atos_poderes_campos_variaveis_tb
 		AFTER INSERT OR UPDATE OR DELETE
 		ON docwin.p_atos_poderes_campos_variaveis_tb
 		FOR EACH ROW
 		EXECUTE PROCEDURE docwin.log_p_ato_tb();
 	END IF;
 
 	CREATE TABLE IF NOT EXISTS docwin.p_atos_rtfs_tb
 	(
 	rt_key bigserial NOT NULL,
 	at_key bigint,
 	rt_descricao text,
 	rt_codigortf text,
 	CONSTRAINT p_ato_rtfs_tb_pkey PRIMARY KEY (rt_key),
 	CONSTRAINT p_ato_rtfs_tb_fkey_p_atos_tb FOREIGN KEY (at_key)
 	REFERENCES docwin.p_atos_tb (at_key) MATCH SIMPLE
 	ON UPDATE CASCADE ON DELETE CASCADE
 	)
 	WITH (
 	OIDS=FALSE
 	);
 	ALTER TABLE docwin.p_atos_rtfs_tb
 	OWNER TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_atos_rtfs_tb TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_atos_rtfs_tb TO escreventes;
 	GRANT ALL ON TABLE docwin.p_atos_rtfs_tb TO supervisores;
 
 	CREATE INDEX IF NOT EXISTS idx_p_atos_tb_data_ato
 	ON docwin.p_atos_tb
 	USING btree
 	(at_dataato);
 
 	CREATE INDEX IF NOT EXISTS idx_p_atos_tb_status
 	ON docwin.p_atos_tb
 	USING hash
 	(at_status);
 
 	IF NOT EXISTS (SELECT trigger_name FROM information_schema.triggers where trigger_name='tgr_p_ato_tb' AND trigger_schema='docwin') THEN
 		CREATE TRIGGER tgr_p_ato_tb
 		AFTER INSERT OR UPDATE OR DELETE
 		ON docwin.p_atos_tb
 		FOR EACH ROW
 		EXECUTE PROCEDURE docwin.log_p_ato_tb();
 	END IF;
 
 	CREATE TABLE IF NOT EXISTS docwin.p_comissoes_user_tb
 	(
 	user_id integer NOT NULL,
 	co_ato double precision,
 	co_subscricao double precision,
 	CONSTRAINT p_comissoes_user_tb_pkey PRIMARY KEY (user_id),
 	CONSTRAINT p_comissoes_user_tb_fkey FOREIGN KEY (user_id)
 	REFERENCES docwin.aux_user_tb (user_id) MATCH SIMPLE
 	ON UPDATE NO ACTION ON DELETE NO ACTION
 	)
 	WITH (
 	OIDS=FALSE
 	);
 	ALTER TABLE docwin.p_comissoes_user_tb
 	OWNER TO postgres;
 	GRANT ALL ON TABLE docwin.p_comissoes_user_tb TO postgres;
 	GRANT ALL ON TABLE docwin.p_comissoes_user_tb TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_comissoes_user_tb TO escreventes;
 	GRANT ALL ON TABLE docwin.p_comissoes_user_tb TO supervisores;
 
 
 	IF NOT EXISTS (SELECT trigger_name FROM information_schema.triggers where trigger_name='tgr_p_comissoes_user_tb' AND trigger_schema='docwin') THEN
 		CREATE TRIGGER tgr_p_comissoes_user_tb
 		AFTER UPDATE OR DELETE
 		ON docwin.p_comissoes_user_tb
 		FOR EACH ROW
 		EXECUTE PROCEDURE docwin.log_p_comissoes_tb();
 	END IF;
 	
 	CREATE TABLE IF NOT EXISTS docwin.p_justificativas_tb
 	(
 	ju_key smallint NOT NULL,
 	ju_titulo text NOT NULL,
 	ju_textopadrao text NOT NULL,
 	CONSTRAINT p_justificativas_tb_pkey PRIMARY KEY (ju_key)
 	)
 	WITH (
 	OIDS=FALSE
 	);
 	ALTER TABLE docwin.p_justificativas_tb
 	OWNER TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_justificativas_tb TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_justificativas_tb TO escreventes;
 	GRANT ALL ON TABLE docwin.p_justificativas_tb TO supervisores;
 
 	
 	CREATE TABLE IF NOT EXISTS docwin.p_log_modificacoes_tb
 	(
 	key bigserial,
 	id bigint,
 	campo_modificado text,
 	tabela text,
 	valor_anterior text,
 	valor_posterior text,
 	data_modificacao timestamp without time zone,
 	usuario text,
 	CONSTRAINT p_log_modificacoes_tb_pkey PRIMARY KEY (key)
 	)
 	WITH (
 	OIDS=FALSE
 	);
 	ALTER TABLE docwin.p_log_modificacoes_tb
 	OWNER TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_log_modificacoes_tb TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_log_modificacoes_tb TO escreventes;
 	GRANT ALL ON TABLE docwin.p_log_modificacoes_tb TO supervisores;
 
 	
 
 	CREATE INDEX IF NOT EXISTS idx_p_log_modificacoes_id_tabela
 	ON docwin.p_log_modificacoes_tb
 	USING hash
 	(tabela COLLATE pg_catalog."default");
 
 	
 	CREATE INDEX IF NOT EXISTS idx_p_log_modificacoes_tb_data
 	ON docwin.p_log_modificacoes_tb
 	USING btree
 	(data_modificacao DESC NULLS LAST);
 
 	
 	CREATE INDEX IF NOT EXISTS idx_p_log_modificacoes_tb_id_tabela
 	ON docwin.p_log_modificacoes_tb
 	USING btree
 	(id, tabela COLLATE pg_catalog."default");
 
 	
 	CREATE INDEX IF NOT EXISTS idx_p_log_modificacoes_tb_id_tabela_data
 	ON docwin.p_log_modificacoes_tb
 	USING btree
 	(id, tabela COLLATE pg_catalog."default", data_modificacao);
 
 	
 	CREATE INDEX IF NOT EXISTS idx_p_log_modificacoes_tb_usuario
 	ON docwin.p_log_modificacoes_tb
 	USING btree
 	(usuario COLLATE pg_catalog."default");
 
 	
 	CREATE TABLE IF NOT EXISTS docwin.p_participantes_representantes_tb
 	(
 	at_key integer NOT NULL,
 	pa_id integer NOT NULL,
 	re_id integer NOT NULL,
 	re_tipo "char" NOT NULL,
 	re_observacoes text,
 	pa_tipo "char",
 	CONSTRAINT p_representantes_tb_pkey PRIMARY KEY (at_key, pa_id, re_id),
 	CONSTRAINT pc_representantes_tb_pc_participantes_tb_fkey FOREIGN KEY (at_key, pa_id, pa_tipo)
 	REFERENCES docwin.p_participantes_tb (at_key, pa_id, pa_tipo) MATCH SIMPLE
 	ON UPDATE CASCADE ON DELETE CASCADE
 	)
 	WITH (
 	OIDS=FALSE
 	);
 	ALTER TABLE docwin.p_participantes_representantes_tb
 	OWNER TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_participantes_representantes_tb TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_participantes_representantes_tb TO escreventes;
 	GRANT ALL ON TABLE docwin.p_participantes_representantes_tb TO supervisores;
 
 	IF NOT EXISTS (SELECT trigger_name FROM information_schema.triggers where trigger_name='tgr_p_participantes_representantes_tb' AND trigger_schema='docwin') THEN
 		CREATE TRIGGER tgr_p_participantes_representantes_tb
 		AFTER INSERT OR UPDATE OR DELETE
 		ON docwin.p_participantes_representantes_tb
 		FOR EACH ROW
 		EXECUTE PROCEDURE docwin.log_p_ato_tb();
 	END IF;
 
 
 	CREATE TABLE IF NOT EXISTS docwin.p_participantes_sefaz_tb
 	(
 	at_key bigint NOT NULL,
 	pa_id bigint NOT NULL,
 	pa_tipo "char" NOT NULL,
 	ps_tipocontribuinte smallint,
 	ps_situacaotributaria "char",
 	ps_opcaorecolhimento "char",
 	ps_datarecolhimento date,
 	ps_valorrecolhimento double precision,
 	CONSTRAINT p_participantes_sefaz_tb_pkey PRIMARY KEY (at_key, pa_id, pa_tipo),
 	CONSTRAINT p_participantes_sefaz_tb_p_participantes_tb_fkey FOREIGN KEY (at_key, pa_id, pa_tipo)
 	REFERENCES docwin.p_participantes_tb (at_key, pa_id, pa_tipo) MATCH SIMPLE
 	ON UPDATE CASCADE ON DELETE CASCADE
 	)
 	WITH (
 	OIDS=FALSE
 	);
 	ALTER TABLE docwin.p_participantes_sefaz_tb
 	OWNER TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_participantes_sefaz_tb TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_participantes_sefaz_tb TO escreventes;
 	GRANT ALL ON TABLE docwin.p_participantes_sefaz_tb TO supervisores;
 
 	IF NOT EXISTS (SELECT trigger_name FROM information_schema.triggers where trigger_name='tg_p_participantes_sefaz_tb' AND trigger_schema='docwin') THEN
 		CREATE TRIGGER tg_p_participantes_sefaz_tb
 		AFTER UPDATE OR DELETE
 		ON docwin.p_participantes_sefaz_tb
 		FOR EACH ROW
 		EXECUTE PROCEDURE docwin.log_p_ato_tb();
 	END IF;
 
 	CREATE TABLE IF NOT EXISTS docwin.p_participantes_rogo_tb
 	(
 	at_key integer NOT NULL,
 	pa_id integer NOT NULL,
 	pa_tipo "char",
 	pf_id integer NOT NULL,
 	ro_motivo "char" NOT NULL,
 	ro_observacao text,
 	CONSTRAINT p_participantes_rogo_tb_pkey PRIMARY KEY (at_key, pa_id, pf_id),
 	CONSTRAINT p_arogoparticipantes_tb_historico_pessoa_fisica_tb FOREIGN KEY (pf_id)
 	REFERENCES docwin.pessoa_fisica_historico_tb (ph_id) MATCH SIMPLE
 	ON UPDATE CASCADE ON DELETE CASCADE,
 	CONSTRAINT p_participantes_rogo_tb_p_participantes_tb_fkey FOREIGN KEY (at_key, pa_id, pa_tipo)
 	REFERENCES docwin.p_participantes_tb (at_key, pa_id, pa_tipo) MATCH SIMPLE
 	ON UPDATE NO ACTION ON DELETE NO ACTION
 	)
 	WITH (
 	OIDS=FALSE
 	);
 	ALTER TABLE docwin.p_participantes_rogo_tb
 	OWNER TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_participantes_rogo_tb TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_participantes_rogo_tb TO escreventes;
 	GRANT ALL ON TABLE docwin.p_participantes_rogo_tb TO supervisores;
 
 	
 	IF NOT EXISTS (SELECT trigger_name FROM information_schema.triggers where trigger_name='tgr_p_participantes_rogo_tb' AND trigger_schema='docwin') THEN
 		CREATE TRIGGER tgr_p_participantes_rogo_tb
 		AFTER INSERT OR UPDATE OR DELETE
 		ON docwin.p_participantes_rogo_tb
 		FOR EACH ROW
 		EXECUTE PROCEDURE docwin.log_p_ato_tb();
 	END IF;
 
 	CREATE TABLE IF NOT EXISTS docwin.p_participantes_testestemunhas_tb
 	(
 	at_key integer NOT NULL,
 	pa_id integer NOT NULL,
 	pa_tipo "char",
 	pf_key integer NOT NULL,
 	ju_key integer NOT NULL,
 	te_justificativa text NOT NULL,
 	CONSTRAINT p_participantestestemunas_tb_pkey PRIMARY KEY (at_key, pa_id, pf_key),
 	CONSTRAINT p_participantes_ato_tb_pessoa_fisica_tb_fkey FOREIGN KEY (pf_key)
 	REFERENCES docwin.pessoa_fisica_historico_tb (ph_id) MATCH SIMPLE
 	ON UPDATE NO ACTION ON DELETE NO ACTION,
 	CONSTRAINT p_participantes_testemunhas_tb_justificativas_tb_fkey FOREIGN KEY (ju_key)
 	REFERENCES docwin.p_justificativas_tb (ju_key) MATCH SIMPLE
 	ON UPDATE NO ACTION ON DELETE NO ACTION,
 	CONSTRAINT p_participantestestemunhas_tb_p_participantes_tb_fkey FOREIGN KEY (at_key, pa_id, pa_tipo)
 	REFERENCES docwin.p_participantes_tb (at_key, pa_id, pa_tipo) MATCH SIMPLE
 	ON UPDATE CASCADE ON DELETE CASCADE
 	)
 	WITH (
 	OIDS=FALSE
 	);
 	ALTER TABLE docwin.p_participantes_testestemunhas_tb
 	OWNER TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_participantes_testestemunhas_tb TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_participantes_testestemunhas_tb TO escreventes;
 	GRANT ALL ON TABLE docwin.p_participantes_testestemunhas_tb TO supervisores;
 
 	IF NOT EXISTS (SELECT trigger_name FROM information_schema.triggers where trigger_name='tgr_p_participantes_testestemunhas_tb' AND trigger_schema='docwin') THEN
 		CREATE TRIGGER tgr_p_participantes_testestemunhas_tb
 		AFTER INSERT OR UPDATE OR DELETE
 		ON docwin.p_participantes_testestemunhas_tb
 		FOR EACH ROW
 		EXECUTE PROCEDURE docwin.log_p_ato_tb();
 	END IF;
 
 	CREATE TABLE IF NOT EXISTS docwin.p_poderes_campos_variaveis_tb
 	(
 	po_key integer NOT NULL,
 	cv_key integer NOT NULL,
 	pc_ordem smallint NOT NULL,
 	CONSTRAINT p_poderes_campos_variaveis_tb_pkey PRIMARY KEY (po_key, cv_key),
 	CONSTRAINT p_poderes_campos_variaveis_tb_campos_fkey FOREIGN KEY (cv_key)
 	REFERENCES docwin.p_campos_variaveis_tb (cv_key) MATCH SIMPLE
 	ON UPDATE CASCADE ON DELETE CASCADE,
 	CONSTRAINT p_poderes_campos_variaveis_tb_fkey FOREIGN KEY (po_key)
 	REFERENCES docwin.p_poderes_tb (po_key) MATCH SIMPLE
 	ON UPDATE CASCADE ON DELETE CASCADE
 	)
 	WITH (
 	OIDS=FALSE
 	);
 	ALTER TABLE docwin.p_poderes_campos_variaveis_tb
 	OWNER TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_poderes_campos_variaveis_tb TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_poderes_campos_variaveis_tb TO escreventes;
 	GRANT ALL ON TABLE docwin.p_poderes_campos_variaveis_tb TO supervisores;
 
 	IF NOT EXISTS (SELECT trigger_name FROM information_schema.triggers where trigger_name='tgr_p_poderes_campos_variaveis_tb' AND trigger_schema='docwin') THEN
 		CREATE TRIGGER tgr_p_poderes_campos_variaveis_tb
 		AFTER UPDATE OR DELETE
 		ON docwin.p_poderes_campos_variaveis_tb
 		FOR EACH ROW
 		EXECUTE PROCEDURE docwin.log_p_poderes_tb();
 	END IF;
 	
 	CREATE TABLE IF NOT EXISTS docwin.p_poderes_exigencias_tb
 	(
 	po_key integer NOT NULL,
 	pe_exigencia smallint NOT NULL,
 	CONSTRAINT p_poderesexigencias_tb_pkey PRIMARY KEY (po_key, pe_exigencia),
 	CONSTRAINT p_poderesexigencias_tb_po_key_fkey FOREIGN KEY (po_key)
 	REFERENCES docwin.p_poderes_tb (po_key) MATCH SIMPLE
 	ON UPDATE CASCADE ON DELETE CASCADE
 	)
 	WITH (
 	OIDS=FALSE
 	);
 	ALTER TABLE docwin.p_poderes_exigencias_tb
 	OWNER TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_poderes_exigencias_tb TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_poderes_exigencias_tb TO escreventes;
 	GRANT ALL ON TABLE docwin.p_poderes_exigencias_tb TO supervisores;
 
 	IF NOT EXISTS (SELECT trigger_name FROM information_schema.triggers where trigger_name='tgr_p_poderes_exigencias_tb' AND trigger_schema='docwin') THEN
 		CREATE TRIGGER tgr_p_poderes_exigencias_tb
 		AFTER UPDATE OR DELETE
 		ON docwin.p_poderes_exigencias_tb
 		FOR EACH ROW
 		EXECUTE PROCEDURE docwin.log_p_poderes_tb();
 	END IF;
 	
 	CREATE TABLE IF NOT EXISTS docwin.p_restricoes_tb
 	(
 	re_key serial NOT NULL,
 	re_documento text NOT NULL,
 	re_descricao text NOT NULL,
 	re_data timestamp without time zone NOT NULL,
 	re_tipo smallint NOT NULL,
 	CONSTRAINT p_restricoes_tb_pkey PRIMARY KEY (re_key)
 	)
 	WITH (
 	OIDS=FALSE
 	);
 	ALTER TABLE docwin.p_restricoes_tb
 	OWNER TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_restricoes_tb TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_restricoes_tb TO escreventes;
 	GRANT ALL ON TABLE docwin.p_restricoes_tb TO supervisores;
 
 	IF NOT EXISTS (SELECT trigger_name FROM information_schema.triggers where trigger_name='tgr_p_restricoes_tb' AND trigger_schema='docwin') THEN
 		CREATE TRIGGER tgr_p_restricoes_tb
 		AFTER INSERT OR UPDATE OR DELETE
 		ON docwin.p_restricoes_tb
 		FOR EACH ROW
 		EXECUTE PROCEDURE docwin.log_p_restricoes_tb();
 	END IF;
 
 	CREATE TABLE IF NOT EXISTS docwin.p_testetmunhas_ato
 	(
 	at_key integer NOT NULL,
 	pf_id integer NOT NULL,
 	ju_key integer NOT NULL,
 	ta_justificativa text NOT NULL,
 	CONSTRAINT p_testemunhas_ato_pkey PRIMARY KEY (at_key, pf_id),
 	CONSTRAINT p_testemunas_ato_tb_atos_tb_fkey FOREIGN KEY (at_key)
 	REFERENCES docwin.p_atos_tb (at_key) MATCH SIMPLE
 	ON UPDATE NO ACTION ON DELETE CASCADE,
 	CONSTRAINT p_testemunhas_ato_tb_justificativas_tb_fkey FOREIGN KEY (ju_key)
 	REFERENCES docwin.p_justificativas_tb (ju_key) MATCH SIMPLE
 	ON UPDATE CASCADE ON DELETE CASCADE,
 	CONSTRAINT p_testemunhas_ato_tb_pessoa_fisica_hist_tb_fkey FOREIGN KEY (at_key)
 	REFERENCES docwin.pessoa_fisica_historico_tb (ph_id) MATCH SIMPLE
 	ON UPDATE NO ACTION ON DELETE CASCADE
 	)
 	WITH (
 	OIDS=FALSE
 	);
 	ALTER TABLE docwin.p_testetmunhas_ato
 	OWNER TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_testetmunhas_ato TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_testetmunhas_ato TO escreventes;
 	GRANT ALL ON TABLE docwin.p_testetmunhas_ato TO supervisores;
 
 	IF NOT EXISTS (SELECT trigger_name FROM information_schema.triggers where trigger_name='tgr_p_testetmunhas_ato' AND trigger_schema='docwin') THEN
 		CREATE TRIGGER tgr_p_testetmunhas_ato
 		BEFORE INSERT OR UPDATE OR DELETE
 		ON docwin.p_testetmunhas_ato
 		FOR EACH ROW
 		EXECUTE PROCEDURE docwin.log_p_ato_tb();
 	END IF;
 		
 	CREATE TABLE IF NOT EXISTS docwin.p_vadi_tb
 	(
 	va_link integer NOT NULL,
 	va_codi smallint NOT NULL,
 	va_cont text,
 	CONSTRAINT p_vadi_tb_pkey PRIMARY KEY (va_link, va_codi),
 	CONSTRAINT p_vadi_tb_va_codi_fkey FOREIGN KEY (va_codi)
 	REFERENCES docwin.p_adic_tb (ad_cod) MATCH SIMPLE
 	ON UPDATE NO ACTION ON DELETE RESTRICT,
 	CONSTRAINT p_vadi_tb_va_link_fkey FOREIGN KEY (va_link)
 	REFERENCES docwin.p_atos_tb (at_key) MATCH SIMPLE
 	ON UPDATE NO ACTION ON DELETE CASCADE
 	)
 	WITH (
 	OIDS=FALSE
 	);
 	ALTER TABLE docwin.p_vadi_tb
 	OWNER TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_vadi_tb TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_vadi_tb TO escreventes;
 	GRANT ALL ON TABLE docwin.p_vadi_tb TO supervisores;
 
 	IF NOT EXISTS (SELECT trigger_name FROM information_schema.triggers where trigger_name='tgr_p_vadi_tb' AND trigger_schema='docwin') THEN
 		CREATE TRIGGER tgr_p_vadi_tb
 		BEFORE INSERT OR UPDATE OF va_cont OR DELETE
 		ON docwin.p_vadi_tb
 		FOR EACH ROW
 		EXECUTE PROCEDURE docwin.log_p_ato_tb();
 	END IF;
 
 	CREATE INDEX IF NOT EXISTS idx_pessoa_fisica_historico_tb
 	ON docwin.pessoa_fisica_historico_tb
 	USING btree
 	(ph_nome COLLATE pg_catalog."default");
 
 	CREATE INDEX IF NOT EXISTS pessoa_fisica_cpf
 	ON docwin.pessoa_fisica_tb
 	USING btree
 	(pf_cpf);
 
 	CREATE TABLE IF NOT EXISTS docwin.p_natureza_escrituras
 	(  
 	ne_id numeric(3,0), 
 	ne_descricao text, 
 	CONSTRAINT p_natureza_escrituras_tb_pkey PRIMARY KEY (ne_id) USING INDEX TABLESPACE pg_default
 	) 
 	WITH (
 	OIDS = FALSE
 	)
 	;
 	ALTER TABLE docwin.p_natureza_escrituras
 	OWNER TO docwin_owner;
 
 	GRANT ALL ON TABLE docwin.p_natureza_escrituras TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_natureza_escrituras TO supervisores;
 	GRANT ALL ON TABLE docwin.p_natureza_escrituras TO escreventes;  
 	-- inserindo dados
 	
 	IF NOT EXISTS (SELECT ne_id FROM docwin.p_natureza_escrituras where ne_id=1) THEN
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (1, 'ACORDO');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (4, 'ALIENA��O');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (5, 'CESS�O');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (6, 'COMPRA');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (10, 'CONFISS�O DE D�VIDA/DA��O EM PAGAMENTO');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (14, 'DECLARA��O');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (15, 'DECLARAT�RIA DE UNI�O EST�VEL');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (16, 'DECLARAT�RIA DE UNI�O EST�VEL HOMOAFETIVA');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (17, 'DESAPROPRIA��O');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (20, 'DISSOLU��O DE UNI�O EST�VEL');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (21, 'DISTRATO');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (22, 'DOA��O');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (23, 'EMANCIPA��O');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (24, 'HIPOTECA');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (25, 'INCORPORA��O');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (26, 'BEM DE FAM�LIA');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (28, 'LOCA��O');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (30, 'PACTO ANTENUPCIAL');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (31, 'PENHOR');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (33, 'PROMESSA DE CESS�O DE DIREITOS AQUISITIVOS');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (34, 'QUITA��O');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (35, 'RERRATIFICA��O');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (36, 'RECONHECIMENTO DE PATERNIDADE');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (38, 'REGISTRO DE CHANCELA MEC�NICA');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (39, 'REMISS�O DE FORO E LAUD�MIOS');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (43, 'SEM VALOR DECLARADO');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (45, 'SERVID�O');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (46, 'USUFRUTO (reserva, institui��o e ren�ncia)');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (48, 'CONDOM�NIO');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (49, 'PARCELAMENTO');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (50, 'SOCIEDADE E FUNDA��ES');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (51, 'TRANSA��O');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (52, 'DIREITO DE USO OU SUPERFICIE');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (53, 'DIVIS�O');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (54, 'FIAN�A');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (55, 'DIRETIVAS ANTECIPADAS DE VONTADE (testamento vital)');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (56, 'CONFER�NCIA');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (57, 'NOVA��O');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (58, 'CR�DITO COM GARANTIA');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (59, 'EMISS�O DE C�DULA');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (60, 'EMISS�O DE DEB�NTURES');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (61, 'REVOGA��O');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (62, 'RENUNCIA DE DIREITOS HEREDIT�RIOS');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (63, 'COMODATO/');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (70, 'PRESTA��O DE SERVI�OS');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (71, 'ARRENDAMENTO MERCANTIL (LEASING)');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (72, 'CONCESS�O DE DOM�NIO');
 		INSERT INTO docwin.p_natureza_escrituras(ne_id, ne_descricao) VALUES (74, 'CONTRATO DE NAMORO');  
 	END IF;
 
 	CREATE TABLE IF NOT EXISTS docwin.p_justificativas_tb
 	(
 	ju_key smallint NOT NULL,
 	ju_titulo text NOT NULL,
 	ju_textopadrao text NOT NULL,
 	CONSTRAINT p_justificativas_tb_pkey PRIMARY KEY (ju_key)
 	)
 	WITH (
 	OIDS=FALSE
 	);
 	ALTER TABLE docwin.p_justificativas_tb
 	OWNER TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_justificativas_tb TO docwin_owner;
 	GRANT ALL ON TABLE docwin.p_justificativas_tb TO escreventes;
 	GRANT ALL ON TABLE docwin.p_justificativas_tb TO supervisores;
 
 	IF NOT EXISTS (SELECT trigger_name FROM information_schema.triggers where trigger_name='tgr_p_justificativas_tb' AND trigger_schema='docwin') THEN
 		CREATE TRIGGER tgr_p_justificativas_tb
 		BEFORE INSERT OR UPDATE OR DELETE
 		ON docwin.p_justificativas_tb
 		FOR EACH ROW
 		EXECUTE PROCEDURE docwin.log_p_justificativas_tb();
 	END IF;
 	
 	IF NOT EXISTS (SELECT cv_key FROM docwin.p_campos_variaveis_tb WHERE cv_key=1) THEN
 		INSERT INTO docwin.p_campos_variaveis_tb VALUES (1, 'Valor (Utilizado no c�lculo do valor base)', 0, '', '', 'Valor');
 		INSERT INTO docwin.p_campos_variaveis_tb VALUES (13, 'Endere�o do Im�vel', 2, '', '', 'Endere�o Im�vel');
 		INSERT INTO docwin.p_campos_variaveis_tb VALUES (12, 'telefone do im�vel', 0, '', '', 'telefone');
 		INSERT INTO docwin.p_campos_variaveis_tb VALUES (15, 'Descri��o do Im�vel', 0, '', '', 'Im�vel');
 		INSERT INTO docwin.p_campos_variaveis_tb VALUES (14, 'Munic�pio do im�vel', 0, '', '', 'Munic�pio');
 		INSERT INTO docwin.p_campos_variaveis_tb VALUES (16, 'Estado do im�vel', 0, '', '', 'Estado');
 		INSERT INTO docwin.p_campos_variaveis_tb VALUES (17, 'valor do im�vel', 0, '', '', 'Valor do im�vel');
 		INSERT INTO docwin.p_campos_variaveis_tb VALUES (18, 'Digitar as matr�culas atuais dos im�veis', 0, '', '', 'Matr�culal atual');
 		INSERT INTO docwin.p_campos_variaveis_tb VALUES (19, 'Digitar as matr�culas anteriores', 0, '', '', 'Matr�cula antiga');
 	END IF;
 END;
  $$  LANGUAGE plpgsql VOLATILE;
 
 
 
 GRANT EXECUTE ON FUNCTION docwin.criatabelasmodulop() TO escreventes;
 GRANT EXECUTE ON FUNCTION docwin.criatabelasmodulop() TO supervisores;
 
 SELECT docwin.criatabelasmodulop();
 
 DROP FUNCTION IF EXISTS docwin.criatabelasmodulop();
 
 
 CREATE TABLE IF NOT EXISTS docwin.p_log_modificacoes_tb
 (
   key bigserial NOT NULL,
   id bigint,
   campo_modificado text,
   tabela text,
   valor_anterior text,
   valor_posterior text,
   data_modificacao timestamp without time zone,
   usuario text,
   CONSTRAINT p_log_modificacoes_tb_pkey PRIMARY KEY (key)
 )
 WITH (
   OIDS=FALSE,
   autovacuum_enabled=true,
   autovacuum_vacuum_threshold=50,
   autovacuum_vacuum_scale_factor=0.2,
   autovacuum_analyze_threshold=50,
   autovacuum_analyze_scale_factor=0.1,
   autovacuum_vacuum_cost_delay=20,
   autovacuum_vacuum_cost_limit=200
 );
 ALTER TABLE docwin.p_log_modificacoes_tb
   OWNER TO docwin_owner;
 GRANT ALL ON TABLE docwin.p_log_modificacoes_tb TO docwin_owner;
 GRANT ALL ON TABLE docwin.p_log_modificacoes_tb TO escreventes;
 GRANT ALL ON TABLE docwin.p_log_modificacoes_tb TO supervisores;
 
 CREATE INDEX IF NOT EXISTS idx_p_log_modificacoes_id_tabela
   ON docwin.p_log_modificacoes_tb
   USING hash
   (tabela COLLATE pg_catalog."default");
 
 -- Index: docwin.idx_p_log_modificacoes_tb_data
 
 -- DROP INDEX docwin.idx_p_log_modificacoes_tb_data;
 
 CREATE INDEX IF NOT EXISTS idx_p_log_modificacoes_tb_data
   ON docwin.p_log_modificacoes_tb
   USING btree
   (data_modificacao DESC NULLS LAST);
 
 -- Index: docwin.idx_p_log_modificacoes_tb_id_tabela
 
 -- DROP INDEX docwin.idx_p_log_modificacoes_tb_id_tabela;
 
 CREATE INDEX IF NOT EXISTS idx_p_log_modificacoes_tb_id_tabela
   ON docwin.p_log_modificacoes_tb
   USING btree
   (id, tabela COLLATE pg_catalog."default");
 
 -- Index: docwin.idx_p_log_modificacoes_tb_id_tabela_data
 
 -- DROP INDEX docwin.idx_p_log_modificacoes_tb_id_tabela_data;
 
 CREATE INDEX IF NOT EXISTS idx_p_log_modificacoes_tb_id_tabela_data
   ON docwin.p_log_modificacoes_tb
   USING btree
   (id, tabela COLLATE pg_catalog."default", data_modificacao);
 
 -- Index: docwin.idx_p_log_modificacoes_tb_usuario
 
 -- DROP INDEX docwin.idx_p_log_modificacoes_tb_usuario;
 
 CREATE INDEX IF NOT EXISTS idx_p_log_modificacoes_tb_usuario
   ON docwin.p_log_modificacoes_tb
   USING btree
   (usuario COLLATE pg_catalog."default");
 
 
 
 
 SELECT pg_catalog.setval('docwin.p_campos_variaveis_tb_cv_key_seq', 19, true);
 
 GRANT ALL ON SEQUENCE docwin.p_atos_assentamentos_tb_aa_key_seq TO docwin_owner;
 GRANT ALL ON SEQUENCE docwin.p_atos_assentamentos_tb_aa_key_seq TO escreventes;
 GRANT ALL ON SEQUENCE docwin.p_atos_assentamentos_tb_aa_key_seq TO supervisores;
 GRANT ALL ON SEQUENCE docwin.p_atos_assentamentos_tb_aa_key_seq TO backup;
 
 GRANT ALL ON SEQUENCE docwin.p_atos_cobrancas_tb_ac_key_seq TO docwin_owner;
 GRANT ALL ON SEQUENCE docwin.p_atos_cobrancas_tb_ac_key_seq TO escreventes;
 GRANT ALL ON SEQUENCE docwin.p_atos_cobrancas_tb_ac_key_seq TO supervisores;
 GRANT ALL ON SEQUENCE docwin.p_atos_cobrancas_tb_ac_key_seq TO backup;
 
 GRANT ALL ON SEQUENCE docwin.p_atos_rtfs_tb_rt_key_seq TO docwin_owner;
 GRANT ALL ON SEQUENCE docwin.p_atos_rtfs_tb_rt_key_seq TO escreventes;
 GRANT ALL ON SEQUENCE docwin.p_atos_rtfs_tb_rt_key_seq TO supervisores;
 GRANT ALL ON SEQUENCE docwin.p_atos_rtfs_tb_rt_key_seq TO backup;
 
 GRANT ALL ON SEQUENCE docwin.p_atos_tb_at_key_seq TO docwin_owner;
 GRANT ALL ON SEQUENCE docwin.p_atos_tb_at_key_seq TO escreventes;
 GRANT ALL ON SEQUENCE docwin.p_atos_tb_at_key_seq TO supervisores;
 GRANT ALL ON SEQUENCE docwin.p_atos_tb_at_key_seq TO backup;
 
 GRANT ALL ON SEQUENCE docwin.p_campos_variaveis_tb_cv_key_seq TO docwin_owner;
 GRANT ALL ON SEQUENCE docwin.p_campos_variaveis_tb_cv_key_seq TO escreventes;
 GRANT ALL ON SEQUENCE docwin.p_campos_variaveis_tb_cv_key_seq TO supervisores;
 GRANT ALL ON SEQUENCE docwin.p_campos_variaveis_tb_cv_key_seq TO backup;
 
 GRANT ALL ON SEQUENCE docwin.p_participantes_tb_at_key_seq TO docwin_owner;
 GRANT ALL ON SEQUENCE docwin.p_participantes_tb_at_key_seq TO escreventes;
 GRANT ALL ON SEQUENCE docwin.p_participantes_tb_at_key_seq TO supervisores;
 GRANT ALL ON SEQUENCE docwin.p_participantes_tb_at_key_seq TO backup;
 
 GRANT ALL ON SEQUENCE docwin.p_poderes_tb_po_key_seq TO docwin_owner;
 GRANT ALL ON SEQUENCE docwin.p_poderes_tb_po_key_seq TO escreventes;
 GRANT ALL ON SEQUENCE docwin.p_poderes_tb_po_key_seq TO supervisores;
 GRANT ALL ON SEQUENCE docwin.p_poderes_tb_po_key_seq TO backup;
 
 GRANT ALL ON SEQUENCE docwin.p_restricoes_tb_re_key_seq TO docwin_owner;
 GRANT ALL ON SEQUENCE docwin.p_restricoes_tb_re_key_seq TO escreventes;
 GRANT ALL ON SEQUENCE docwin.p_restricoes_tb_re_key_seq TO supervisores;
 GRANT ALL ON SEQUENCE docwin.p_restricoes_tb_re_key_seq TO backup;
 
 
 	--FUN��ES 500
 CREATE OR REPLACE FUNCTION docwin.criafuncoesmodulop() RETURNS void as
  $$ 
 BEGIN 
 	IF NOT EXISTS (SELECT fu_cod FROM docwin.aux_func_tb WHERE fu_cod=1 AND fu_mod='P')
 	THEN
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (1, 'P', E'C�digo interno do ato', E'Campo do banco de dados. C�digo interno do ato num�rico.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (2, 'P', E'Nome do Livro', E'Campo do banco de dados. Este campo cont�m o nome do livro utilizado na lavratura do ato.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (3, 'P', E'N� do Livro', E'Campo do banco de dados. Este campo cont�m o n�mero do livro utilizado na lavratura do ato.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (4, 'P', E'P�gina inicial do Livro', E'Campo do banco de dados. Este campo cont�m o n�mero da primeira p�gina do livro utilizado na lavratura do ato.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (5, 'P', E'P�gina final do Livro', E'Campo do banco de dados. Este campo cont�m o n�mero da �ltima p�gina do livro utilizado na lavratura do ato.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (6, 'P', E'Data da lavratura do ato', E'Campo do banco de dados. Este campo cont�m a data da lavratura ato.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (7, 'P', E'Hora da lavratura do ato', E'Campo do banco de dados. Este campo cont�m a hora da lavratura ato.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (8, 'P', E'Reserva de poderes', E'Campo do banco de dados. Este campo cont�m a informa��o se houve ou n�o reserva de poderes. Valores retornados : sim ou n�o.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (11, 'P', E'Tipo do ato lavrado', E'Campo do banco de dados. Este campo cont�m a informa��o do tipo do ato lavrado. Ex.: Procura��o, escritura, etc.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (12, 'P', E'Ato original: Nome do Livro', E'Campo do banco de dados. Este campo cont�m o nome do livro utilizado na lavratura do ato original que est� sendo revogado, substabelecido ou renunciado.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (13, 'P', E'Ato original: N� do Livro', E'Campo do banco de dados. Este campo cont�m o n�mero do livro utilizado na lavratura do ato original que est� sendo revogado, substabelecido ou renunciado.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (14, 'P', E'Ato original: P�gina do Livro', E'Campo do banco de dados. Este campo cont�m o n�mero da primeira p�gina do livro utilizado na lavratura do ato original que est� sendo revogado, substabelecido ou renunciado.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (15, 'P', E'Ato original: P�gina final do Livro', E'Campo do banco de dados. Este campo cont�m o n�mero da �ltima p�gina do livro utilizado na lavratura do ato original que est� sendo revogado, substabelecido ou renunciado.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (16, 'P', E'Ato original: Data da lavratura do ato', E'Campo do banco de dados. Este campo cont�m a data da lavratura ato original que est� sendo revogado, substabelecido ou renunciado.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (17, 'P', E'Ato original: Local da lavratura em c�digo', E'Campo do banco de dados. Este campo cont�m o local da lavratura do ato original que est� sendo revogado, substabelecido ou renunciado. Ex: Nesta serventia, Outra Serventia, Servi�o consular ou desconhecido.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (18, 'P', E'Ato original: nome da serventia/local', E'Campo do banco de dados. Este campo cont�m o nome ou descri��o do local da lavratura do ato original que est� sendo revogado, substabelecido ou renunciado.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (19, 'P', E'Ato original: CEP do logradouro do local de lavratura', E'Campo do banco de dados. Este campo cont�m o cep do local da lavratura do ato original que est� sendo revogado, substabelecido ou renunciado.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (20, 'P', E'Ato original: Logradouro do local de lavratura', E'Campo do banco de dados. Este campo cont�m o logradouro do local da lavratura do ato original que est� sendo revogado, substabelecido ou renunciado.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (21, 'P', E'Ato original: NumeroEndereco endere�o do local de lavratura', E'Campo do banco de dados. Este campo cont�m o n�mero do logradouro do local da lavratura do ato original que est� sendo revogado, substabelecido ou renunciado.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (22, 'P', E'Ato original: Bairro endere�o do local de lavratura', E'Campo do banco de dados. Este campo cont�m o bairro do local da lavratura do ato original que est� sendo revogado, substabelecido ou renunciado.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (23, 'P', E'Ato original: Cidade endere�o do local de lavratura', E'Campo do banco de dados. Este campo cont�m o nome da cidade do local da lavratura do ato original que est� sendo revogado, substabelecido ou renunciado.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (24, 'P', E'Ato original: UF endere�o do local de lavratura', E'Campo do banco de dados. Este campo cont�m a sigla da UF do local da lavratura do ato original que est� sendo revogado, substabelecido ou renunciado.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (25, 'P', E'Ato original: Complemento endere�o do local de lavratura', E'Campo do banco de dados. Este campo cont�m o complemento do logradouro do local da lavratura do ato original que est� sendo revogado, substabelecido ou renunciado.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (26, 'P', E'Ato original: Pais endere�o do local de lavratura', E'Campo do banco de dados. Este campo cont�m o nome do pa�s do local da lavratura do ato original que est� sendo revogado, substabelecido ou renunciado.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (27, 'P', E'Ato original: Permitia substabelecimento', E'Campo do banco de dados. Este campo cont�m a informa��o se permitia ou n�o substabelecer o ato original que est� sendo revogado, substabelecido ou renunciado.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (28, 'P', E'Ato original: Permitia revoga��o', E'Campo do banco de dados. Este campo cont�m a informa��o se permitia ou n�o revogar o ato original que est� sendo revogado, substabelecido ou renunciado.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (30, 'P', E'Nome do usuario que lavrou o ato', E'Campo do banco de dados. Este campo cont�m o nome do usu�rio que lavrou o ato.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (31, 'P', E'Fun��o do usuario que lavrou o ato', E'Campo do banco de dados. Este campo cont�m a fun��o do usu�rio que lavrou o ato.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (32, 'P', E'Nome do usuario que subscreveu o ato', E'Campo do banco de dados. Este campo cont�m o nome do usu�rio que subscreveu o ato.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (33, 'P', E'Fun��o do usuario que subscreveu o ato', E'Campo do banco de dados. Este campo cont�m a fun��o do usu�rio que subscreveu o ato.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (34, 'P', E'Substabelecimento', E'Campo do banco de dados. Este campo cont�m a informa��o se � ou n�o permitido substabelecer o ato lavrado.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (35, 'P', E'Tipo de prazo de validade', E'Campo do banco de dados. Este campo cont�m a informa��o do tipo de validade deste ato. Ex.: Por data ou por per�odo.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (36, 'P', E'Data de validade', E'Campo do banco de dados. Este campo cont�m a data de validade do ato lavrado.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (37, 'P', E'Prazo, em anos', E'Campo do banco de dados. Este campo cont�m o prazo de validade em anos.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (38, 'P', E'Prazo, em meses', E'Campo do banco de dados. Este campo cont�m o prazo de validade em meses', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (39, 'P', E'Prazo, em dias', E'Campo do banco de dados. Este campo cont�m o prazo de validade em dias', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (40, 'P', E'Campo de uso livre', E'Campo do banco de dados. Este campo cont�m a informa��o digitada no campo "Uso livre" na aba de dados iniciais na tela de lavratura do ato.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (41, 'P', E'Nome do usuario que lavrou a certid�o', E'Campo do banco de dados. Este campo cont�m o nome do usu�rio que lavrou a certid�o.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (42, 'P', E'Fun��o do usuario que lavrou a certid�o', E'Campo do banco de dados. Este campo cont�m a fun��o do usu�rio que lavrou a certid�o.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (43, 'P', E'Nome do usuario que subscreveu a certid�o', E'Campo do banco de dados. Este campo cont�m o nome do usu�rio que subscreveu a certid�o.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (44, 'P', E'Fun��o do usuario que subscreveu a certid�o', E'Campo do banco de dados. Este campo cont�m a fun��o do usu�rio que subscreveu a certid�o.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (45, 'P', E'Em dilig�ncia?', E'Campo do banco de dados. Este campo cont�m a informa��o se este ato foi lavrado em dilig�ncia.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (46, 'P', E'Local da dilig�ncia', E'Campo do banco de dados. Este campo cont�m local do ato lavrado em dilig�ncia.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (500, 'P', E'Qualifica��o completa dos outorgantes', E'Fun��o. Qualifica��o completa dos outorgantes do ato. Ex.: FULANO DE TAL, nacionalidade Brasileira, maior, estado civil solteiro(a), profiss�o xxxxxxxx, filho(a) de Jos� e Maria, portador do CPF xxxxxxxxx, etc.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (501, 'P', E'Qualifica��o resumida dos outorgantes', E'Fun��o. Qualifica��o resumida dos outorgantes do ato. Ex.: FULANO DE TAL, Brasileira, maior, solteiro(a), engenheiro, filho(a) de Jos� e Maria, portador do CPF xxxxxxxxx, etc.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (502, 'P', E'Nome dos outorgantes', E'Fun��o. Retorna os nomes dos outorgantes do ato. OBS: Pode ser alterada a prefer�ncia "resumir nomes dos outorgantes". Neste caso ser� mostrado , em caso de mais de 2 outogantes cadastrado, o primeiro em ordem alfab�tica e complementado por "e OUTROS". EX.: FULANO DE TAL e OUTROS.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (505, 'P', E'Presentes reconhecidos', E'Fun��o. Retorna a frase : "O presente reconhecido como sendo o pr�prio de que trato, assina a testemunha abaixo qualificada, que a conhece e a identifica, apresentando nesta oportunidade os documentos em seus originais, do que dou f�".', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (510, 'P', E'Qualifica��o completa dos outorgados ou renunciantes', E'Fun��o. Qualifica��o completa dos outorgados/renunciantes do ato. Ex.: FULANO DE TAL, nacionalidade Brasileira, maior, estado civil solteiro(a), profiss�o xxxxxxxx, filho(a) de Jos� e Maria, portador do CPF xxxxxxxxx, etc.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (511, 'P', E'Qualifica��o resumida dos outorgados ou renunciantes', E'Fun��o. Qualifica��o resumida dos outorgados/renunciantes do ato. Ex.: FULANO DE TAL, Brasileira, maior, solteiro(a), engenheiro, filho(a) de Jos� e Maria, portador do CPF xxxxxxxxx, etc.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (512, 'P', E'Nome dos outorgados ou renunciantes', E'Fun��o. Nomes de todos outorgados/renunciantes do ato.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (515, 'P', E'Poderes do ato', E'Fun��o. Retorna os poderes atribuidos a este ato.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (516, 'P', E'Total valor base para c�lculo de emolumentos', E'Fun��o. Retorna o valor base para c�lculo de emolumentos.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (520, 'P', E'Central de indisponibilidade', E'Fun��o. Retorna o texto com o resultado das consultas realizadas na central de indisponibilidade. Ex:. Foi consultada a Central de Indisponibilidades de Bens ..., sendo o resultado negativo, ou seja, n�o consta restri��o � disposi��o de bens, para FULANO, c�digo hash XXXXX,... sendo o resultado positivo, ou seja, consta restri��o � disposi��o de bens, para FULANA, estando o mesmo com seus bens atingidos...etc.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (529, 'P', E'Quem lavrou/subscreveu o ato (nomes (fun��o))', E'Fun��o. Retorna o nome com a fun��o do usu�rio. Ex.: Fulano (o oficial).', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (530, 'P', E'Quem lavrou/subscreveu o ato (espa�o para rubrica)', E'Fun��o. Retorna o nome com a fun��o do usu�rio. Ex.: EU                                     Fulano (o oficial), lavrei, digitei, conferi, subscrevi, dou f� e assino.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (531, 'P', E'Quem lavrou/subscreveu o ato (aa)', E'Fun��o. Retorna o nome com a fun��o do usu�rio. Ex.: Fulano (o oficial).', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (532, 'P', E'Quem lavrou/subscreveu a/o certid�o/traslado (espa�o para rubrica)', E'Fun��o. Retorna o nome com a fun��o do usu�rio. Ex.: EU                                     Fulano (o oficial), lavrei, digitei, conferi, subscrevi, dou f� e assino.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (534, 'P', E'Permitia substabelecimento', E'Fun��o. Retorna o texto "Substabelecimento feito por insist�ncia da parte, conforme lhe faculta o artigo 667 do C�digo Civil Brasileiro e seus par�grafos, estando a parte plenamente ciente da responsabilidade civil que o presente ato pode lhe gerar."', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (535, 'P', E'Permitia revoga��o', E'Fun��o. Retorna o texto "Revoga��o feita por insist�ncia da parte, conforme lhe faculta o artigo 683 do C�digo Civil Brasileiro, estando a parte plenamente ciente da responsabilidade civil que o presente ato pode lhe gerar.".', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (536, 'P', E'Nome e endere�o da serventia do ato original', E'Fun��o. Retorna o nome e endere�o da serventia do ato original.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (560, 'P', E'A rogo dos outorgantes', E'Fun��o. Retorna a frase "Lido e achado conforme, assina a rogo de FULANO" e a qualifica��o completa do assinante a rogo.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (575, 'P', E'Testemunhas ', E'Fun��o. Retorna o texto "Assinam (quantidade de testemunhas)  testemunhas que atestam conhecer FULANO " e a qualifica��o completa da testemunha.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (576, 'P', E'Testemunhas para Traslado', E'Fun��o. Retorna o texto "Assinaram (quantidade de testemunhas)  testemunhas que atestaram conhecer FULANO " e a qualifica��o completa da testemunha.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (577, 'P', E'Testemunhas dispensa', E'Fun��o. Retorna a frase "O outorgante declara que dispensa a presen�a e assinatura de testemunhas" ou "O renunciante declara que dispensa a presen�a e assinatura de testemunhas".', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (578, 'P', E'Testemunhas dispensa para Traslado/Certid�o', E'Fun��o. Retorna a frase "O outorgante declarou que dispensa a presen�a e assinatura de testemunhas" ou "O renunciante declarou que dispensa a presen�a e assinatura de testemunhas".', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (579, 'P', E'Tem Testemunha?', E'Fun��o. Retorna se existe ou n�o testemunhas no ato. OBS: incluindo as testemunhas dos participantes.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (594, 'P', E'Nome completo do usuario logado', E'Fun��o. Retorna o nome completo do usu�rio logado.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (595, 'P', E'Funcao do usuario logado na serventia ', E'Fun��o. Retorna a fun��o do usu�rio logado.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (598, 'P', E'Data do dia no formato dd/MM/aaaa', E'Fun��o. Retorna a data do dia no formato dd/mm/aaaa. Ex.: 30/01/2016.', 0, 'F');
 		INSERT INTO docwin.aux_func_tb(fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo) VALUES (599, 'P', E'Data do dia com m�s por extenso.', E'Fun��o. Retorna a data do dia com m�s por extenso. Ex.: 30 de janeiro de 2016.', 0, 'F');
 		--FUN��ES 600
 		INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) VALUES (600, 'P', 'Data por extenso', 'Fun��o especial. Voc�, ao escolher esta fun��o, tamb�m seleciona qual data quer o extenso e qual o tipo do extenso a ser usado!', 2, 'F', NULL, NULL, NULL, NULL);
 		INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) VALUES (603, 'P', 'N�mero por extenso', 'Fun��o especial. Retorna um n�mero por extenso.', 1, 'F', NULL, NULL, NULL, NULL);
 		INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) VALUES (601, 'P', 'Validade da procura��o', 'Fun��o especial: Retorna a informa��o da validade da procura��o.', 2, 'F', NULL, NULL, NULL, NULL);
 		INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) VALUES (604, 'P', 'Valor monet�rio por extenso', 'Fun��o especial. Retorna um valor por extenso (em reais).', 1, 'F', NULL, NULL, NULL, NULL);
 		INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) VALUES (605, 'P', 'Assinantes do ato', 'Fun��o especial. Retorna o nome de todos que assinam o ato (um por linha).', 2, 'F', NULL, NULL, NULL, NULL);
 		INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) VALUES (607, 'P', 'Assentamentos acess�rios com controle de "vide-verso"', 'Fun��o especial. Retorna o tipo do assentamento acess�rio e seu conte�do. Se o texto for longo (muitas linhas) indica "vide-verso"', 3, 'F', NULL, NULL, NULL, NULL);
 		INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) VALUES (608, 'P', 'Concatena constantes ao conte�do de um campo ou fun��o', 'Fun��o especial. Retorna uma constante � esquerda (prefixo) e/ou � direita (sufixo) se conte�do do campo ou fun��o estiver preenchido.', 2, 'F', NULL, NULL, NULL, NULL);
 		INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) VALUES (609, 'P', 'Verifica condi��o definida e retorna conte�do conforme o resultado', 'Fun��o especial. Verifica se a condi��o definida e dependendo do resultado (verdadeiro ou falso) retorna um conte�do espec�fico.', 2, 'F', NULL, NULL, NULL, NULL);
 		INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) VALUES (610, 'P', 'Numero do selo/certid�o utilizado na impress�o', 'Retorna o n�mero da certid�o ou selo indicado que foi utilizado na impress�o do documento. Se n�o houver selo/certid�o vinculado, o conte�do vir� em branco. Se houver um v�nculo mas n�o houver selo/certid�o utilizado, ser� impresso a abrevia��o do modelo. Exemplo: [CER]', 0, 'F', NULL, NULL, NULL, NULL);
 		INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) VALUES (615, 'P', 'UF por extenso', 'Fun��o especial. Retorna nome da UF por extenso. Adicionalmente deve-se indicar se o extenso � simples (0) ou completo (1).', 2, 'F', NULL, NULL, NULL, NULL);
 		INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) VALUES (616, 'P', 'Altera formato mai�sculo / min�sculo.', 'Fun��o. Retorna em formato mai�sculo ou min�sculo.', 2, 'F', NULL, NULL, NULL, NULL);
 		INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) VALUES (620, 'P', 'N�mero de controle do selo digital utilizado na impress�o', 'Retorna o n�mero de controle do selo digital. Se n�o houver selo/certid�o vinculado, o conte�do vir� em branco. Se houver um v�nculo mas n�o houver selo/certid�o utilizado, ser� impresso a abrevia��o do modelo. Exemplo: [CER]', 0, 'F', NULL, NULL, NULL, NULL);
 		INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) VALUES (617, 'P', 'Condicional do g�nero/qtde de outorgantes', 'Fun��o especial. Testa a quantidade e o g�nero de todos os outorgantes.', 2, 'F', NULL, NULL, NULL, NULL);
 		INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) VALUES (618, 'P', 'Condicional do g�nero/qtde de outorgados', 'Fun��o especial. Testa a quantidade e o g�nero de todos os outorgados.', 2, 'F', NULL, NULL, NULL, NULL);
 		INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) VALUES (619, 'P', 'Conte�do conforme campo permitia substabelecimento', 'Fun��o especial. Retorna o valor do par�metro de acordo com o tipo de substabelecimento do ato.', 2, 'F', NULL, NULL, NULL, NULL);
 		INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) VALUES (635, 'P', 'Assinantes do ato para traslado/certid�o', 'Fun��o especial. Retorna os nomes dos assinantes do ato (um ap�s ao outro).', 2, 'F', NULL, NULL, NULL, NULL);
 		INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) VALUES (636, 'P', 'Assinantes da/o certid�o/traslado', 'Fun��o especial. Assinante da certid�o.', 2, 'F', NULL, NULL, NULL, NULL);
 		INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) VALUES (634, 'P', 'Informa��p do livro e folhas', 'Fun��o especial. Retorna as informa��es do livro e folha onde foi registrado o ato.', 2, 'F', NULL, NULL, NULL, NULL);
 		INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) VALUES (637, 'P', 'Valores de custas e emolumentos (Cobran�a atual)', 'Fun��o com Parametros. Retorna valores de custas e emolumentos do Ato (� necess�rio usar ato padronizado)', 1, 'F', NULL, NULL, NULL, NULL);
 		INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) VALUES (638, 'P', 'Valores de custas e emolumentos (Primeira cobran�a)', 'Fun��o com Parametros. Retorna valores de custas e emolumentos da primeira cobran�a do Ato (� necess�rio usar ato padronizado)', 1, 'F', NULL, NULL, NULL, NULL);
 
 		INSERT INTO docwin.aux_func_lnk_tb(lk_cod, lk_lnk, lk_mod) VALUES (600, 6, 'P');
 		INSERT INTO docwin.aux_func_lnk_tb(lk_cod, lk_lnk, lk_mod) VALUES (600, 36, 'P');
 		INSERT INTO docwin.aux_func_lnk_tb(lk_cod, lk_lnk, lk_mod) VALUES (600, 598, 'P');
 		INSERT INTO docwin.aux_func_lnk_tb(lk_cod, lk_lnk, lk_mod) VALUES (601, 35, 'P');
 		INSERT INTO docwin.aux_func_lnk_tb(lk_cod, lk_lnk, lk_mod) VALUES (603, 37, 'P');
 		INSERT INTO docwin.aux_func_lnk_tb(lk_cod, lk_lnk, lk_mod) VALUES (603, 38, 'P');
 		INSERT INTO docwin.aux_func_lnk_tb(lk_cod, lk_lnk, lk_mod) VALUES (603, 39, 'P');
 		INSERT INTO docwin.aux_func_lnk_tb(lk_cod, lk_lnk, lk_mod) VALUES (603, 24, 'P');
 		INSERT INTO docwin.aux_func_lnk_tb(lk_cod, lk_lnk, lk_mod) VALUES (619, 34, 'P');
 	END IF;
 	
 	IF NOT EXISTS (SELECT tf_id FROM docwin.aux_tfun_tb WHERE tf_id=611)
 	THEN
 		INSERT INTO docwin.aux_tfun_tb VALUES (601, 'P_INCLUI', 'Incluir atos (Menu)', NULL, '');
 		INSERT INTO docwin.aux_tfun_tb VALUES (602, 'P_PESQ', 'Pesquisar registros', NULL, 'AP');
 		INSERT INTO docwin.aux_tfun_tb VALUES (603, 'P_CONFIG', 'Configura��es (Menu)', NULL, '');
 		INSERT INTO docwin.aux_tfun_tb VALUES (604, 'P_INCNORM', 'Incluir ato', 601, 'IAP');
 		INSERT INTO docwin.aux_tfun_tb VALUES (606, 'P_INCINDX', 'Incluir �ndice', 601, 'IA');
 		INSERT INTO docwin.aux_tfun_tb VALUES (607, 'P_PODINP', 'Poderes (Menu)', NULL, '');
 		INSERT INTO docwin.aux_tfun_tb VALUES (608, 'P_PODINC', 'Incluir poder', 607, 'IA');
 		INSERT INTO docwin.aux_tfun_tb VALUES (609, 'P_PODPES', 'Pesquisar poderes', 607, 'A');
 		INSERT INTO docwin.aux_tfun_tb VALUES (610, 'P_PODCMPV', 'Campos vari�vies', 607, 'IA');		
 		INSERT INTO docwin.aux_tfun_tb VALUES (611, 'P_DDOC', 'Defini��o de documentos', 603, 'IEAP');
 		INSERT INTO docwin.aux_tfun_tb VALUES (612, 'P_DIMG', 'Defini��o de imagens', 603, 'IEA');
 		INSERT INTO docwin.aux_tfun_tb VALUES (613, 'P_NUMAUTO', 'Numera��o autom�tica', 603, 'A');
 		INSERT INTO docwin.aux_tfun_tb VALUES (615, 'P_VARADI', 'Vari�veis adicionais', 603, 'IEA');
 		INSERT INTO docwin.aux_tfun_tb VALUES (616, 'P_VARGLO', 'Vari�veis globais', 603, 'IEA');
 		INSERT INTO docwin.aux_tfun_tb VALUES (617, 'P_CMSSES', 'Comiss�es', NULL, 'IA');
 		INSERT INTO docwin.aux_tfun_tb VALUES (618, 'P_JUSTTT', 'Justificativas de testemunhas', NULL, 'IA');
 		INSERT INTO docwin.aux_tfun_tb VALUES (619, 'P_RESTDOC', 'Restri��es de documentos ', NULL, 'IAE');	
 		INSERT INTO docwin.aux_tfun_tb VALUES (620, 'P_ESTTCS', 'Estat�sticas (Menu)', NULL, NULL);
 		INSERT INTO docwin.aux_tfun_tb VALUES (621, 'P_CEPCSC', 'CEP - Censec', 620, NULL);
 		INSERT INTO docwin.aux_tfun_tb VALUES (622, 'P_ALTMTPO', 'Permite alterar texto do poder ap�s substituir os campos vari�veis', 601, 'A');
 		INSERT INTO docwin.aux_tfun_tb VALUES (623, 'P_ALTATO', 'Permite alterar o ato ap�s impresso', 601, 'A');
 		INSERT INTO docwin.aux_tfun_tb VALUES (624, 'P_PFRNCS', 'Permite alterar prefer�ncias e configura��es do m�dulo de notas', NULL, 'A');
 		INSERT INTO docwin.aux_tfun_tb VALUES (625, 'P_ATOLOG', 'Permite acessar os logs de modifica��es do ato.', 603, NULL);
 		INSERT INTO docwin.aux_tfun_tb VALUES (701, 'R_INCLUI', 'Incluir atos (Menu)', NULL, '');
 		INSERT INTO docwin.aux_tfun_tb VALUES (702, 'R_PESQ', 'Pesquisar registros', NULL, 'AP');
 		INSERT INTO docwin.aux_tfun_tb VALUES (703, 'R_CONFIG', 'Configura��es (Menu)', NULL, '');
 		INSERT INTO docwin.aux_tfun_tb VALUES (704, 'R_INCNORM', 'Incluir ato', 701, 'IAP');
 		INSERT INTO docwin.aux_tfun_tb VALUES (706, 'R_INCINDX', 'Incluir �ndice', 701, 'IA');
 		INSERT INTO docwin.aux_tfun_tb VALUES (711, 'R_DDOC', 'Defini��o de documentos', 703, 'IEAP');
 		INSERT INTO docwin.aux_tfun_tb VALUES (712, 'R_DIMG', 'Defini��o de imagens', 703, 'IEA');
 		INSERT INTO docwin.aux_tfun_tb VALUES (713, 'R_NUMAUTO', 'Numera��o autom�tica', 703, 'A');
 		INSERT INTO docwin.aux_tfun_tb VALUES (715, 'R_VARADI', 'Vari�veis adicionais', 703, 'IEA');
 		INSERT INTO docwin.aux_tfun_tb VALUES (716, 'R_VARGLO', 'Vari�veis globais', 703, 'IEA');
 		INSERT INTO docwin.aux_tfun_tb VALUES (720, 'R_ESTTCS', 'Estat�sticas (Menu)', NULL, NULL);
 		INSERT INTO docwin.aux_tfun_tb VALUES (721, 'R_CEPCSC', 'CEP - Censec', 720, NULL);
 		INSERT INTO docwin.aux_tfun_tb VALUES (722, 'R_CSDCSC', 'CESDI - Censec', 720, NULL);
 		INSERT INTO docwin.aux_tfun_tb VALUES (723, 'R_RTOCSC', 'RTCO - Censec', 720, NULL);
 		INSERT INTO docwin.aux_tfun_tb VALUES (724, 'R_SEFZSP', 'SEFAZ/SP', 720, NULL);
 		INSERT INTO docwin.aux_tfun_tb VALUES (725, 'R_ATOLOG', 'Permite acessar os logs de modifica��es do ato.', 703, NULL);
 	END IF;
 	
 	IF EXISTS(SELECT column_name FROM information_schema.columns WHERE table_schema='docwin' AND table_name='aux_preferencias_tb' 
 																								 AND column_name='nome' AND data_type='character varying') THEN
 		ALTER TABLE docwin.aux_preferencias_tb ALTER COLUMN nome TYPE text;
 	END IF;
 
 	
 END;
  $$  LANGUAGE plpgsql VOLATILE;
 
 GRANT EXECUTE ON FUNCTION docwin.criafuncoesmodulop() TO escreventes;
 GRANT EXECUTE ON FUNCTION docwin.criafuncoesmodulop() TO supervisores;
 
 SELECT docwin.criafuncoesmodulop();
 
 DROP FUNCTION IF EXISTS docwin.criafuncoesmodulop();
 
 CREATE OR REPLACE FUNCTION docwin.alteracaogustavo() RETURNS void as
  $$ 
 BEGIN 
 		IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
                    WHERE table_schema='docwin' AND table_name='pessoa_fisica_historico_tb' AND column_name='ph_ufnascimento')
 		THEN
 			ALTER TABLE docwin.pessoa_fisica_historico_tb ADD COLUMN ph_ufnascimento character(2);
 		END IF;
 		IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
                    WHERE table_schema='docwin' AND table_name='pessoa_fisica_historico_tb' AND column_name='ph_cidadenascimento')
 		THEN
 			ALTER TABLE docwin.pessoa_fisica_historico_tb ADD COLUMN ph_cidadenascimento text;
 		END IF;
 		IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
                    WHERE table_schema='docwin' AND table_name='pessoa_fisica_historico_tb' AND column_name='ph_paisnascimento')
 		THEN
 			ALTER TABLE docwin.pessoa_fisica_historico_tb ADD COLUMN ph_paisnascimento text;
 		END IF;
 		IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
                    WHERE table_schema='docwin' AND table_name='pessoa_fisica_tb' AND column_name='pf_ufnascimento')
 		THEN
 			ALTER TABLE docwin.pessoa_fisica_tb ADD COLUMN pf_ufnascimento character(2);
 		END IF;
 		IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
                    WHERE table_schema='docwin' AND table_name='pessoa_fisica_tb' AND column_name='pf_cidadenascimento')
 		THEN
 			ALTER TABLE docwin.pessoa_fisica_tb ADD COLUMN pf_cidadenascimento text;
 		END IF;
 		IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
                    WHERE table_schema='docwin' AND table_name='pessoa_fisica_tb' AND column_name='pf_paisnascimento')
 		THEN
 			ALTER TABLE docwin.pessoa_fisica_tb ADD COLUMN pf_paisnascimento text;
 		END IF;
 				
 		IF NOT EXISTS (SELECT table_name FROM information_schema.tables 
                    WHERE table_schema='docwin' AND table_name='aux_comunicacao_arpen_tb')
 		THEN	
 			
 			CREATE TABLE IF NOT EXISTS docwin.aux_comunicacao_arpen_tb
 			(
 			  codigo_arpen bigint NOT NULL,
 			  idregistro bigint,
 			  modulo "char",
 			  CONSTRAINT aux_comunicacao_arpen_pkey PRIMARY KEY (codigo_arpen)
 			)
 			WITH (
 			  OIDS=FALSE
 			);
 			ALTER TABLE docwin.aux_comunicacao_arpen_tb
 			  OWNER TO postgres;
 			GRANT ALL ON TABLE docwin.aux_comunicacao_arpen_tb TO postgres;
 			GRANT ALL ON TABLE docwin.aux_comunicacao_arpen_tb TO docwin_owner;
 			GRANT ALL ON TABLE docwin.aux_comunicacao_arpen_tb TO escreventes;
 			GRANT ALL ON TABLE docwin.aux_comunicacao_arpen_tb TO supervisores;
 			
 		END IF;	
 				
 		IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
                    WHERE table_schema='docwin' AND table_name='u_item_ordem_servico_tb' AND column_name='lnk_ato')
 		THEN
 			ALTER TABLE docwin.u_item_ordem_servico_tb ADD COLUMN lnk_ato bigint;
 			COMMENT ON COLUMN docwin.u_item_ordem_servico_tb.lnk_ato IS 'ID do ato/registro que originou a cobran�a.';
 		END IF;
 
 		IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
                    WHERE table_schema='docwin' AND table_name='u_item_ordem_servico_tb' AND column_name='modulo')
 		THEN
 			ALTER TABLE docwin.u_item_ordem_servico_tb ADD COLUMN modulo "char";
 			COMMENT ON COLUMN docwin.u_item_ordem_servico_tb.modulo IS 'Modulo do ato/registro que originou a cobran�a.';
 		END IF;
 
 		IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
                    WHERE table_schema='docwin' AND table_name='u_ato_padronizado_tb' AND column_name='qtde_faixa')
 		THEN
 			ALTER TABLE docwin.u_ato_padronizado_tb ADD COLUMN qtde_faixa smallint;
 			COMMENT ON COLUMN docwin.u_ato_padronizado_tb.qtde_faixa IS 'Quantidade da faixa inicial que � multiplicada o item do ato (Notas)';
 		END IF;
 
 		IF NOT EXISTS (SELECT fu_cod FROM docwin.aux_func_tb WHERE fu_cod=637 AND fu_mod='P')
 		THEN
 			INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) 
 			VALUES (637, 'P', 'Valores de custas e emolumentos', 'Fun��o com Parametros. Retorna valores de custas e emolumentos do Ato (� necess�rio usar ato padronizado)', 1, 'F', 
 			NULL, NULL, NULL, NULL);
 		END IF;
 
 		IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
                    WHERE table_schema='docwin' AND table_name='aux_para_tb' AND column_name='pa_codcolegionotarial')
 		THEN
 			ALTER TABLE docwin.aux_para_tb ADD COLUMN pa_codcolegionotarial text;
 		END IF;
 		
 		IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
                    WHERE table_schema='docwin' AND table_name='aux_para_tb' AND column_name='pa_cnpj_serventia')
 		THEN
 			ALTER TABLE docwin.aux_para_tb ADD COLUMN pa_cnpj_serventia text;
 		END IF;		
 		
 		CREATE TABLE IF NOT EXISTS docwin.aux_menus_dinamicos_tb
 		(												
 		  chave text NOT NULL,
 		  descricao text,
 		  duplo boolean,
 		  cor text,
 		  imagem smallint,
 		  ordem smallint,
 		  userid bigint NOT NULL,
 		  CONSTRAINT aux_menus_dinamicos_tb_pkey PRIMARY KEY (chave, userid)
 		)
 		WITH (
 		  OIDS=FALSE
 		);
 		ALTER TABLE docwin.aux_menus_dinamicos_tb
 		  OWNER TO docwin_owner;
 		GRANT ALL ON TABLE docwin.aux_menus_dinamicos_tb TO docwin_owner;
 		GRANT ALL ON TABLE docwin.aux_menus_dinamicos_tb TO escreventes;
 		GRANT ALL ON TABLE docwin.aux_menus_dinamicos_tb TO supervisores;										
 		
 		IF NOT EXISTS(SELECT chave FROM docwin.aux_menus_dinamicos_tb WHERE chave='menusToolStripMenuItem' AND userid=0) THEN
 			INSERT INTO docwin.aux_menus_dinamicos_tb VALUES ('menusToolStripMenuItem', 'Alterar atalhos', false, '-16469069', 38, 1, 0);
 		END IF;
 		
 	
 		IF EXISTS (SELECT column_name FROM information_schema.columns 
                    WHERE table_schema='docwin' AND table_name='u_ordem_servico_tb' AND column_name='controle' AND data_type='integer')
 		THEN
 			ALTER TABLE docwin.u_ordem_servico_tb
 				ALTER COLUMN controle TYPE text;
 		END IF;	
 		
 		UPDATE docwin.aux_func_tb
 		   SET fu_tit=replace(fu_tit,'Caracteriza��o', 'Qualifica��o')
 		 WHERE fu_mod='N' AND fu_tit LIKE 'Caracteriza��o%';
 		 
 		 PERFORM docwin.inserealterahelp('A','C','ACNIEDF','   
     Define  se ser� ou n�o inserido
     o  endere�o na qualifica��o dos 
     pais (nas fun��es @554 e @555).','Endere�o na qualifica��o');
 		
 	
 		IF NOT EXISTS (SELECT fu_cod FROM docwin.aux_func_tb WHERE fu_cod=655 AND fu_mod='C')
 		THEN	
 			INSERT INTO docwin.aux_func_tb(
 						fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, 
 						fu_mask, fu_cont, fu_altera)
 			VALUES (655, 'C', 'Dados do registro de casamento anterior ou nascimento do contraente 1', 'Fun��o: Dados do registro de casamento anterior (se preenchidos) ou nascimento (caso n�o houver casamento anterior) do contraente 1',
 					0, 'F', NULL, NULL, NULL, NULL);
 
 
 			INSERT INTO docwin.aux_func_tb(
 						fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, 
 						fu_mask, fu_cont, fu_altera)
 			VALUES (656, 'C', 'Dados do registro de casamento anterior ou nascimento do contraente 2', 'Fun��o: Dados do registro de casamento anterior (se preenchidos) ou nascimento (caso n�o houver casamento anterior) do contraente 2',
 					0, 'F', NULL, NULL, NULL, NULL);
 		END IF;
 		
 		IF NOT EXISTS (SELECT fu_cod FROM docwin.aux_func_tb WHERE fu_cod=543 AND fu_mod='E')
 		THEN	
 			INSERT INTO docwin.aux_func_tb(
 						fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, 
 						fu_mask, fu_cont, fu_altera)
 			VALUES (543, 'E', 'Dados do registro de casamento anterior ou nascimento do contraente 1', 'Fun��o: Dados do registro de casamento anterior (se preenchidos) ou nascimento (caso n�o houver casamento anterior) do contraente 1',
 					0, 'F', NULL, NULL, NULL, NULL);
 
 
 			INSERT INTO docwin.aux_func_tb(
 						fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, 
 						fu_mask, fu_cont, fu_altera)
 			VALUES (544, 'E', 'Dados do registro de casamento anterior ou nascimento do contraente 2', 'Fun��o: Dados do registro de casamento anterior (se preenchidos) ou nascimento (caso n�o houver casamento anterior) do contraente 2',
 					0, 'F', NULL, NULL, NULL, NULL);
 		END IF;
		
		IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
 					   WHERE table_schema='docwin' AND table_name='f_def_termos_tb' AND column_name='dt_idetiqueta')
 			THEN
 				ALTER TABLE docwin.f_def_termos_tb
 					ADD COLUMN dt_idetiqueta integer;
 				
 				UPDATE docwin.f_def_termos_tb SET dt_idetiqueta=(SELECT CASE WHEN valor IS NULL THEN -1 ELSE valor::int END 
 																FROM docwin.f_preferencias_tb where nome='etq_termo_cod');
 
 			END IF;			
 		
 		IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
 					   WHERE table_schema='docwin' AND table_name='s_compartilhamento_tb' AND column_name='cmp_primeiro')
 		THEN
 			ALTER TABLE docwin.s_compartilhamento_tb ADD COLUMN cmp_primeiro bigint;
 			UPDATE docwin.s_compartilhamento_tb SET cmp_primeiro = cmp_proximo;
 		END IF;
 		
 		IF NOT EXISTS (SELECT tf_id FROM docwin.aux_tfun_tb WHERE tf_id=341)
 		THEN
 			INSERT INTO docwin.aux_tfun_tb VALUES (341, 'F_RPRINT', 'Reimprimir etiquetas de reconhecimento e/ou autentica��o', 306, 'P');
 		END IF;
 	
 END;
  $$  LANGUAGE plpgsql VOLATILE;
 
 GRANT EXECUTE ON FUNCTION docwin.alteracaogustavo() TO escreventes;
 GRANT EXECUTE ON FUNCTION docwin.alteracaogustavo() TO supervisores;
 
 SELECT docwin.alteracaogustavo();
 
 DROP FUNCTION IF EXISTS docwin.alteracaogustavo();
 
 GRANT ALL ON SEQUENCE docwin.p_log_modificacoes_tb_key_seq TO docwin_owner;
 GRANT ALL ON SEQUENCE docwin.p_log_modificacoes_tb_key_seq TO supervisores;
 GRANT ALL ON SEQUENCE docwin.p_log_modificacoes_tb_key_seq TO escreventes;
 GRANT ALL ON SEQUENCE docwin.p_log_modificacoes_tb_key_seq TO backup;
 
 
 -- Function: docwin.inseresaidaselagem(bigint, bigint, text, date, text, text, text, integer, integer, text, smallint, text, character varying, text, text, text, text, integer, text, text, integer, integer, text, integer, bigint, bigint, smallint, boolean, integer, text, integer, integer)
 
 -- DROP FUNCTION docwin.inseresaidaselagem(bigint, bigint, text, date, text, text, text, integer, integer, text, smallint, text, character varying, text, text, text, text, integer, text, text, integer, integer, text, integer, bigint, bigint, smallint, boolean, integer, text, integer, integer);
 
 CREATE OR REPLACE FUNCTION docwin.inseresaidaselagem(
     IN inicial bigint,
     IN final bigint,
     IN i_serie text,
     IN i_data date,
     IN i_status text,
     IN i_observacoes text,
     IN i_registro text,
     IN i_modelo integer,
     IN i_requerente integer,
     IN i_matricula text,
     IN i_class smallint,
     IN i_gerado text,
     IN i_user_login character varying,
     IN i_nomecivil text,
     IN i_nomecivil2 text,
     IN i_cpfcnpj text,
     IN i_selodigital text,
     IN i_qtdassin integer,
     IN i_ip text,
     IN i_nomelivro text,
     IN i_numerolivro integer,
     IN i_numerofolha integer,
     IN i_frenteverso text,
     IN i_numerotermo integer,
     IN i_ato_key bigint,
     IN i_selo_retificado bigint,
     IN i_ato_padronizado smallint,
     IN i_ato_gratuito boolean,
     IN i_numero_protocolo integer,
     IN i_selo_principal text,
     IN i_emolumento integer,
     IN i_tipo_tributacao integer,
     OUT i bigint)
   RETURNS bigint AS
  $BODY$ 
 DECLARE
  x bigint;
 BEGIN
  x := inicial;
  WHILE (x <= final) LOOP
   INSERT INTO docwin.s_saida_tb (sai_serie, sai_numselo, sai_data  , sai_status, sai_observacoes, sai_registro, sai_modelo, sai_requerente, sai_matricula, sai_class, sai_gerado, sai_user_login, sai_nomecivil, sai_nomecivil2, sai_cpfcnpj, sai_selodigital, sai_qtdassin, sai_hora, sai_ip, sai_nomelivro, sai_numerolivro, sai_numerofolha, sai_frenteverso, sai_numerotermo, ato_key, selo_retificado, ato_padronizado, ato_gratuito, numero_protocolo, selo_principal, emolumento, tipo_tributacao) 
           VALUES   (i_serie, x, i_data , i_status, i_observacoes, i_registro, i_modelo, i_requerente, i_matricula, i_class, i_gerado, i_user_login, i_nomecivil, i_nomecivil2, i_cpfcnpj, i_selodigital, i_qtdassin, now()   , i_ip  , i_nomelivro, i_numerolivro, i_numerofolha, i_frenteverso, i_numerotermo, i_ato_key, i_selo_retificado, i_ato_padronizado, i_ato_gratuito, i_numero_protocolo, i_selo_principal, i_emolumento, i_tipo_tributacao) ;
   x := x + 1;
  END LOOP;
     i := x - 1;
 END;
  $BODY$ 
   LANGUAGE plpgsql VOLATILE
   COST 100;
 ALTER FUNCTION docwin.inseresaidaselagem(bigint, bigint, text, date, text, text, text, integer, integer, text, smallint, text, character varying, text, text, text, text, integer, text, text, integer, integer, text, integer, bigint, bigint, smallint, boolean, integer, text, integer, integer)
   OWNER TO postgres;
 GRANT EXECUTE ON FUNCTION docwin.inseresaidaselagem(bigint, bigint, text, date, text, text, text, integer, integer, text, smallint, text, character varying, text, text, text, text, integer, text, text, integer, integer, text, integer, bigint, bigint, smallint, boolean, integer, text, integer, integer) TO public;
 GRANT EXECUTE ON FUNCTION docwin.inseresaidaselagem(bigint, bigint, text, date, text, text, text, integer, integer, text, smallint, text, character varying, text, text, text, text, integer, text, text, integer, integer, text, integer, bigint, bigint, smallint, boolean, integer, text, integer, integer) TO postgres;
 GRANT EXECUTE ON FUNCTION docwin.inseresaidaselagem(bigint, bigint, text, date, text, text, text, integer, integer, text, smallint, text, character varying, text, text, text, text, integer, text, text, integer, integer, text, integer, bigint, bigint, smallint, boolean, integer, text, integer, integer) TO docwin_owner;
 GRANT EXECUTE ON FUNCTION docwin.inseresaidaselagem(bigint, bigint, text, date, text, text, text, integer, integer, text, smallint, text, character varying, text, text, text, text, integer, text, text, integer, integer, text, integer, bigint, bigint, smallint, boolean, integer, text, integer, integer) TO supervisores;
 
  
 CREATE OR REPLACE FUNCTION docwin.colunas() RETURNS void as
  $$ 
 BEGIN
 
 	IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
                    WHERE table_schema='docwin' AND table_name='u_ordem_servico_tb' AND column_name='conta')
     THEN
 		ALTER TABLE docwin.u_ordem_servico_tb ADD COLUMN conta  smallint;
     END IF;
 	
 	IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
                    WHERE table_schema='docwin' AND table_name='u_ordem_servico_tb' AND column_name='hora_os')
     THEN
 		ALTER TABLE docwin.u_ordem_servico_tb ADD COLUMN hora_os time without time zone;
     END IF;
 	
 		IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
                    WHERE table_schema='docwin' AND table_name='aux_cliente_tb' AND column_name='cl_bloqueado')
     THEN
 		ALTER TABLE docwin.aux_cliente_tb ADD COLUMN cl_bloqueado boolean;
     END IF;
  
 END;
 

   $$  LANGUAGE plpgsql VOLATILE;

  GRANT EXECUTE ON FUNCTION docwin.colunas() TO escreventes;

  GRANT EXECUTE ON FUNCTION docwin.colunas() TO supervisores;

  SELECT docwin.colunas();

  DROP FUNCTION IF EXISTS docwin.colunas(); 
  
  
  
 
 CREATE OR REPLACE FUNCTION docwin.colunas() RETURNS void as
$$
BEGIN

	IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
                   WHERE table_schema='docwin' AND table_name='u_ordem_servico_tb' AND column_name='conta')
    THEN
		ALTER TABLE docwin.u_ordem_servico_tb ADD COLUMN conta  smallint;
    END IF;
	
	IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
                   WHERE table_schema='docwin' AND table_name='u_ordem_servico_tb' AND column_name='hora_os')
    THEN
		ALTER TABLE docwin.u_ordem_servico_tb ADD COLUMN hora_os time without time zone;
    END IF;
	
		IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
                   WHERE table_schema='docwin' AND table_name='aux_cliente_tb' AND column_name='cl_bloqueado')
    THEN
		ALTER TABLE docwin.aux_cliente_tb ADD COLUMN cl_bloqueado boolean;
    END IF;
	
	
	 IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
                   WHERE table_schema='docwin' AND table_name='aux_para_tb' AND column_name='pa_email')
    THEN
		ALTER TABLE docwin.aux_para_tb ADD COLUMN pa_email text;
    END IF;
	
		
	IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
                   WHERE table_schema='docwin' AND table_name='u_ordem_servico_tb' AND column_name='last_update')
    THEN
		ALTER TABLE docwin.u_ordem_servico_tb ADD COLUMN last_update TIMESTAMP;
    END IF;
	
	
 
END;
$$ LANGUAGE plpgsql VOLATILE;
GRANT EXECUTE ON FUNCTION docwin.colunas() TO escreventes;
GRANT EXECUTE ON FUNCTION docwin.colunas() TO supervisores;
SELECT docwin.colunas();
DROP FUNCTION IF EXISTS docwin.colunas(); 


 
CREATE OR REPLACE FUNCTION docwin.criarFuncoes() RETURNS void as
$$
BEGIN


	IF NOT EXISTS (SELECT * FROM docwin.aux_func_tb WHERE fu_cod = 480 and fu_mod = 'F')
    THEN
	INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) 
           VALUES (480, 'F', 'C�digo do Ato de selagem',
                   'Fun��o: Retorna o c�digo do Ato de selagem vinculado a modalidade.', 0, 'F', 
				   NULL, NULL, NULL, NULL);
    END IF;
	
	
		IF NOT EXISTS (SELECT * FROM docwin.aux_func_tb WHERE fu_cod = 496 and fu_mod = 'F')
    THEN
	INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) 
           VALUES (496, 'F', 'Nome do oficial',
                   'Fun��o: Retorna Nome do oficial titular da serventia', 0, 'F', 
				   NULL, NULL, NULL, NULL);
    END IF;
	
		IF NOT EXISTS (SELECT * FROM docwin.aux_func_tb WHERE fu_cod = 497 and fu_mod = 'F')
    THEN
	INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) 
           VALUES (497, 'F', 'Nome do substituto do oficial da serventia',
                   'Fun��o: Retorna Nome do substituto do oficial da serventia', 0, 'F', 
				   NULL, NULL, NULL, NULL);
    END IF;
	
	
		IF NOT EXISTS (SELECT * FROM docwin.aux_func_tb WHERE fu_cod = 498 and fu_mod = 'F')
    THEN
	INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) 
           VALUES (498, 'F', 'E-mail da Serventia',
                   'Fun��o: Retorna o e-mail da Serventia', 0, 'F', 
				   NULL, NULL, NULL, NULL);
    END IF;
	
			IF NOT EXISTS (SELECT * FROM docwin.aux_func_tb WHERE fu_cod = 499 and fu_mod = 'F')
    THEN
	INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) 
           VALUES (499, 'F', 'Telefone da Serventia',
                   'Fun��o: Retorna o n�mero de telefone da Serventia', 0, 'F', 
				   NULL, NULL, NULL, NULL);
    END IF;
	
	
	
END;
$$ LANGUAGE plpgsql VOLATILE;
GRANT EXECUTE ON FUNCTION docwin.criarFuncoes() TO escreventes;
GRANT EXECUTE ON FUNCTION docwin.criarFuncoes() TO supervisores;
SELECT docwin.criarFuncoes();
DROP FUNCTION IF EXISTS docwin.criarFuncoes();
  
 
 CREATE OR REPLACE FUNCTION docwin.criarPermissoes() RETURNS void as
$$
BEGIN

	IF NOT EXISTS (SELECT * FROM docwin.aux_tfun_tb WHERE tf_id = 406)
	THEN
		INSERT INTO docwin.aux_tfun_tb(tf_id, tf_prog, tf_nomfun, tf_sub, tf_perm)
		VALUES (406, 'U_FINOSDP', 'Finalizar Ordens de Servi�o com valor do dep�sito pr�vio igual ao valor total de atos', 400, '');
	END IF;
 
END;
$$ LANGUAGE plpgsql VOLATILE;
GRANT EXECUTE ON FUNCTION docwin.criarPermissoes() TO escreventes;
GRANT EXECUTE ON FUNCTION docwin.criarPermissoes() TO supervisores;
SELECT docwin.criarPermissoes();
DROP FUNCTION IF EXISTS docwin.criarPermissoes();



 
 CREATE OR REPLACE FUNCTION docwin.colunas() RETURNS void as
$$
BEGIN

	IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
                   WHERE table_schema='docwin' AND table_name='u_ordem_servico_tb' AND column_name='conta')
    THEN
		ALTER TABLE docwin.u_ordem_servico_tb ADD COLUMN conta  smallint;
    END IF;
	
	IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
                   WHERE table_schema='docwin' AND table_name='u_ordem_servico_tb' AND column_name='hora_os')
    THEN
		ALTER TABLE docwin.u_ordem_servico_tb ADD COLUMN hora_os time without time zone;
    END IF;
	
		IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
                   WHERE table_schema='docwin' AND table_name='aux_cliente_tb' AND column_name='cl_bloqueado')
    THEN
		ALTER TABLE docwin.aux_cliente_tb ADD COLUMN cl_bloqueado boolean;
    END IF;
	
	
	 IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
                   WHERE table_schema='docwin' AND table_name='aux_para_tb' AND column_name='pa_email')
    THEN
		ALTER TABLE docwin.aux_para_tb ADD COLUMN pa_email text;
    END IF;
	
		
	IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
                   WHERE table_schema='docwin' AND table_name='u_ordem_servico_tb' AND column_name='last_update')
    THEN
		ALTER TABLE docwin.u_ordem_servico_tb ADD COLUMN last_update TIMESTAMP;
    END IF;
	
	IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
                   WHERE table_schema='docwin' AND table_name='aux_imgs_tb' AND column_name='img_compat_2013')
    THEN
		ALTER TABLE docwin.aux_imgs_tb ADD COLUMN img_compat_2013 boolean default false;
	END IF;
	
 
END;
$$ LANGUAGE plpgsql VOLATILE;
GRANT EXECUTE ON FUNCTION docwin.colunas() TO escreventes;
GRANT EXECUTE ON FUNCTION docwin.colunas() TO supervisores;
SELECT docwin.colunas();
DROP FUNCTION IF EXISTS docwin.colunas(); 


 
CREATE OR REPLACE FUNCTION docwin.criarFuncoes() RETURNS void as
$$
BEGIN


	IF NOT EXISTS (SELECT * FROM docwin.aux_func_tb WHERE fu_cod = 480 and fu_mod = 'F')
    THEN
	INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) 
           VALUES (480, 'F', 'C�digo do Ato de selagem',
                   'Fun��o: Retorna o c�digo do Ato de selagem vinculado a modalidade.', 0, 'F', 
				   NULL, NULL, NULL, NULL);
    END IF;
	
	
		IF NOT EXISTS (SELECT * FROM docwin.aux_func_tb WHERE fu_cod = 496 and fu_mod = 'F')
    THEN
	INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) 
           VALUES (496, 'F', 'Nome do oficial',
                   'Fun��o: Retorna Nome do oficial titular da serventia', 0, 'F', 
				   NULL, NULL, NULL, NULL);
    END IF;
	
		IF NOT EXISTS (SELECT * FROM docwin.aux_func_tb WHERE fu_cod = 497 and fu_mod = 'F')
    THEN
	INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) 
           VALUES (497, 'F', 'Nome do substituto do oficial da serventia',
                   'Fun��o: Retorna Nome do substituto do oficial da serventia', 0, 'F', 
				   NULL, NULL, NULL, NULL);
    END IF;
	
	
		IF NOT EXISTS (SELECT * FROM docwin.aux_func_tb WHERE fu_cod = 498 and fu_mod = 'F')
    THEN
	INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) 
           VALUES (498, 'F', 'E-mail da Serventia',
                   'Fun��o: Retorna o e-mail da Serventia', 0, 'F', 
				   NULL, NULL, NULL, NULL);
    END IF;
	
			IF NOT EXISTS (SELECT * FROM docwin.aux_func_tb WHERE fu_cod = 499 and fu_mod = 'F')
    THEN
	INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) 
           VALUES (499, 'F', 'Telefone da Serventia',
                   'Fun��o: Retorna o n�mero de telefone da Serventia', 0, 'F', 
				   NULL, NULL, NULL, NULL);
    END IF;
	
	
	
END;
$$ LANGUAGE plpgsql VOLATILE;
GRANT EXECUTE ON FUNCTION docwin.criarFuncoes() TO escreventes;
GRANT EXECUTE ON FUNCTION docwin.criarFuncoes() TO supervisores;
SELECT docwin.criarFuncoes();
DROP FUNCTION IF EXISTS docwin.criarFuncoes();

  
 
 CREATE OR REPLACE FUNCTION docwin.criarPermissoes() RETURNS void as
$$
BEGIN

	IF NOT EXISTS (SELECT * FROM docwin.aux_tfun_tb WHERE tf_id = 406)
	THEN
		INSERT INTO docwin.aux_tfun_tb(tf_id, tf_prog, tf_nomfun, tf_sub, tf_perm)
		VALUES (406, 'U_FINOSDP', 'Finalizar Ordens de Servi�o com valor do dep�sito pr�vio igual ao valor total de atos', 400, '');
	END IF;
 
END;
$$ LANGUAGE plpgsql VOLATILE;
GRANT EXECUTE ON FUNCTION docwin.criarPermissoes() TO escreventes;
GRANT EXECUTE ON FUNCTION docwin.criarPermissoes() TO supervisores;
SELECT docwin.criarPermissoes();
DROP FUNCTION IF EXISTS docwin.criarPermissoes();






--Corre��o ortogr�fica
UPDATE docwin.aux_tfun_tb SET  tf_nomfun= replace(tf_nomfun, 'pr�pias','pr�prias');
UPDATE docwin.aux_tfun_tb SET  tf_nomfun= replace(tf_nomfun, 'vari�vies','Vari�veis');




 
CREATE OR REPLACE FUNCTION docwin.criarFuncoes() RETURNS void as
$$
BEGIN


	IF NOT EXISTS (SELECT * FROM docwin.aux_func_tb WHERE fu_cod = 212 and fu_mod = 'F')
    THEN
	INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) 
           VALUES (212, 'F', 'Quem compareceu',
                   'Fun��o: Retorna as informa��es de quem compareceu, incluindo dados do representante caso houver (Para Termo de Comparecimento)', 0, 'F', 
				   NULL, NULL, NULL, NULL);
    END IF;
	
	
 
	
END;
$$ LANGUAGE plpgsql VOLATILE;
GRANT EXECUTE ON FUNCTION docwin.criarFuncoes() TO escreventes;
GRANT EXECUTE ON FUNCTION docwin.criarFuncoes() TO supervisores;
SELECT docwin.criarFuncoes();
DROP FUNCTION IF EXISTS docwin.criarFuncoes();




CREATE OR REPLACE FUNCTION docwin.criarPermissoes() RETURNS void as
$$
BEGIN

	IF NOT EXISTS (SELECT * FROM docwin.aux_tfun_tb WHERE tf_id = 32)
	THEN
		INSERT INTO docwin.aux_tfun_tb(tf_id, tf_prog, tf_nomfun, tf_sub, tf_perm)
		VALUES (32, 'N_EDITDOC', 'Editar conte�do do documento em tempo de execu��o. (Impress�o DOC-Printer - Text-Control)', null, '');
	END IF;
	
		IF NOT EXISTS (SELECT * FROM docwin.aux_tfun_tb WHERE tf_id = 82)
	THEN
		INSERT INTO docwin.aux_tfun_tb(tf_id, tf_prog, tf_nomfun, tf_sub, tf_perm)
		VALUES (82, 'O_EDITDOC', 'Editar conte�do do documento em tempo de execu��o. (Impress�o DOC-Printer - Text-Control)', null, '');
	END IF;
	
	IF NOT EXISTS (SELECT * FROM docwin.aux_tfun_tb WHERE tf_id = 143)
	THEN
		INSERT INTO docwin.aux_tfun_tb(tf_id, tf_prog, tf_nomfun, tf_sub, tf_perm)
		VALUES (143, 'C_EDITDOC', 'Editar conte�do do documento em tempo de execu��o. (Impress�o DOC-Printer - Text-Control)', null, '');
	END IF;
	
    IF NOT EXISTS (SELECT * FROM docwin.aux_tfun_tb WHERE tf_id = 157)
	THEN
		INSERT INTO docwin.aux_tfun_tb(tf_id, tf_prog, tf_nomfun, tf_sub, tf_perm)
		VALUES (157, 'A_EDITDOC', 'Editar conte�do do documento em tempo de execu��o. (Impress�o DOC-Printer - Text-Control)', null, '');
	END IF;
	
	
	IF NOT EXISTS (SELECT * FROM docwin.aux_tfun_tb WHERE tf_id = 220)
	THEN
		INSERT INTO docwin.aux_tfun_tb(tf_id, tf_prog, tf_nomfun, tf_sub, tf_perm)
		VALUES (220, 'S_EDITDOC', 'Editar conte�do do documento em tempo de execu��o. (Impress�o DOC-Printer - Text-Control)', null, '');
	END IF;
	
	
	IF NOT EXISTS (SELECT * FROM docwin.aux_tfun_tb WHERE tf_id = 267)
	THEN
		INSERT INTO docwin.aux_tfun_tb(tf_id, tf_prog, tf_nomfun, tf_sub, tf_perm)
		VALUES (267, 'E_EDITDOC', 'Editar conte�do do documento em tempo de execu��o. (Impress�o DOC-Printer - Text-Control)', null, '');
	END IF;
	
	
	IF NOT EXISTS (SELECT * FROM docwin.aux_tfun_tb WHERE tf_id = 342)
	THEN
		INSERT INTO docwin.aux_tfun_tb(tf_id, tf_prog, tf_nomfun, tf_sub, tf_perm)
		VALUES (342, 'F_EDITDOC', 'Editar conte�do do documento em tempo de execu��o. (Impress�o DOC-Printer - Text-Control)', null, '');
	END IF;
	
	
    IF NOT EXISTS (SELECT * FROM docwin.aux_tfun_tb WHERE tf_id = 466)
	THEN
		INSERT INTO docwin.aux_tfun_tb(tf_id, tf_prog, tf_nomfun, tf_sub, tf_perm)
		VALUES (466, 'V_EDITDOC', 'Editar conte�do do documento em tempo de execu��o. (Impress�o DOC-Printer - Text-Control)', null, '');
	END IF;
	
	IF NOT EXISTS (SELECT * FROM docwin.aux_tfun_tb WHERE tf_id = 507)
	THEN
		INSERT INTO docwin.aux_tfun_tb(tf_id, tf_prog, tf_nomfun, tf_sub, tf_perm)
		VALUES (507, 'P_EDITDOC', 'Editar conte�do do documento em tempo de execu��o. (Impress�o DOC-Printer - Text-Control)', null, '');
	END IF;
	
	IF NOT EXISTS (SELECT * FROM docwin.aux_tfun_tb WHERE tf_id = 626)
	THEN
		INSERT INTO docwin.aux_tfun_tb(tf_id, tf_prog, tf_nomfun, tf_sub, tf_perm)
		VALUES (626, 'R_EDITDOC', 'Editar conte�do do documento em tempo de execu��o. (Impress�o DOC-Printer - Text-Control)', null, '');
	END IF;
	
	IF NOT EXISTS (SELECT * FROM docwin.aux_tfun_tb WHERE tf_id = 726)
	THEN
		INSERT INTO docwin.aux_tfun_tb(tf_id, tf_prog, tf_nomfun, tf_sub, tf_perm)
		VALUES (726, 'U_EDITDOC', 'Editar conte�do do documento em tempo de execu��o. (Impress�o DOC-Printer - Text-Control)', null, '');
	END IF;
	
	
 
	
 
END;
$$ LANGUAGE plpgsql VOLATILE;
GRANT EXECUTE ON FUNCTION docwin.criarPermissoes() TO escreventes;
GRANT EXECUTE ON FUNCTION docwin.criarPermissoes() TO supervisores;
SELECT docwin.criarPermissoes();
DROP FUNCTION IF EXISTS docwin.criarPermissoes();


-- 0.5 - 0.60

CREATE OR REPLACE FUNCTION docwin.log_p_ato_tb()
  RETURNS trigger AS 
$BODY$ 
 DECLARE
     ri RECORD;
     campo_novo TEXT;
     campo_antigo text;
 BEGIN
 	
  if (quote_ident(TG_relname) = 'p_participantes_tb') then
 	if ( TG_OP = 'INSERT') then	
 		insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 
 				   (new.at_key   ,'Participante inserido'      ,quote_ident(TG_relname), ''            ,(SELECT CASE  WHEN new.pa_tipo = 'F' THEN 
 								(SELECT 'CPF n� ' || lpad(ph_cpf::text, 11,'0') FROM docwin.pessoa_fisica_historico_tb WHERE new.pa_id = ph_id) ELSE 
 								(SELECT 'CNPJ n� ' || lpad(pjh_cnpj::text,15,'0') FROM docwin.pessoa_juridica_historico_tb WHERE new.pa_id = pjh_id) END)      ,now()            ,user);
 	else 
 		if ( TG_OP = 'DELETE') then
 			insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 
 				 (old.at_key    ,'Participante excluído'      	,quote_ident(TG_relname), (SELECT CASE  WHEN old.pa_tipo = 'F' THEN 
 								(SELECT 'CPF n� ' || lpad(ph_cpf::text, 11,'0') FROM docwin.pessoa_fisica_historico_tb WHERE old.pa_id = ph_id) ELSE 
 								(SELECT 'CNPJ n� ' || lpad(pjh_cnpj::text,15,'0') FROM docwin.pessoa_juridica_historico_tb WHERE old.pa_id = pjh_id) END)  ,''		,now()        		,user);
 		end if;	
 	end if;
 
     FOR ri IN
         SELECT  column_name
         FROM information_schema.columns
         WHERE
             table_schema = quote_ident(TG_TABLE_SCHEMA)
         AND table_name = quote_ident(TG_TABLE_NAME)
         ORDER BY ordinal_position
     LOOP
 	if ( TG_OP = 'UPDATE') then		
 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_antigo using old;
 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_novo using NEW;
 		if campo_novo <> campo_antigo then
 			insert into docwin.p_log_modificacoes_tb (id      , campo_modificado, tabela                , valor_anterior  , valor_posterior, data_modificacao, usuario) values 
 				        (old.at_key  ,ri.column_name || ' do participante ' ||  (SELECT CASE  WHEN old.pa_tipo = 'F' THEN 
 								(SELECT 'CPF n� ' || lpad(ph_cpf::text, 11,'0') FROM docwin.pessoa_fisica_historico_tb WHERE old.pa_id = ph_id) ELSE 
 								(SELECT 'CNPJ n� ' || lpad(pjh_cnpj::text,15,'0') FROM docwin.pessoa_juridica_historico_tb WHERE old.pa_id = pjh_id) END)   || ' do ato ' || (SELECT 'Livro ' || at_livronome::text || '-' || (CASE WHEN at_livronumero < 0 THEN '*' ELSE at_livronumero::text END) 
 			|| ', Pag. ini. '  || (CASE WHEN at_folhanumero < 0 THEN '*' ELSE at_folhanumero::text END) 
 			|| ' e Pag. final. '  || (CASE WHEN at_folhanumerofinal < 0 THEN '*' ELSE at_folhanumerofinal::text END)
 				FROM docwin.p_atos_tb WHERE at_key=old.at_key)   ,quote_ident(TG_relname), campo_antigo    ,campo_novo      ,now()      ,user);
                 end if;
         end if;       
     END LOOP;
     RETURN NEW;
 
 elseif (quote_ident(TG_relname) = 'p_participantes_representantes_tb') then
 	if ( TG_OP = 'INSERT') then	
 		insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 
 				   (new.at_key   ,'Representante inserido'      ,quote_ident(TG_relname), ''            ,((SELECT CASE  WHEN new.re_tipo = 'F' THEN 
 								(SELECT 'Representante ' || ph_nome FROM docwin.pessoa_fisica_historico_tb WHERE new.re_id = ph_id) ELSE 
 								(SELECT 'Representante ' || pjh_razao FROM docwin.pessoa_juridica_historico_tb WHERE new.re_id = pjh_id) END) || ' do participante ' || (SELECT CASE  WHEN pa_tipo = 'F' THEN 
 								(SELECT 'CPF n� ' || lpad(ph_cpf::text, 11,'0') FROM docwin.pessoa_fisica_historico_tb WHERE new.pa_id = ph_id) ELSE 
 								(SELECT 'CNPJ n� ' || lpad(pjh_cnpj::text,15,'0') FROM docwin.pessoa_juridica_historico_tb WHERE new.pa_id = pjh_id) END 
 								 FROM docwin.p_participantes_tb WHERE p_participantes_tb.at_key = new.at_key AND p_participantes_tb.pa_id = new.pa_id))      ,now()            ,user);
 	else 
 		if ( TG_OP = 'DELETE') then
 			insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 
 				 (old.at_key    ,'Representante excluído'      	,quote_ident(TG_relname), ((SELECT CASE  WHEN old.re_tipo = 'F' THEN 
 								(SELECT 'Representante ' || ph_nome FROM docwin.pessoa_fisica_historico_tb WHERE old.re_id = ph_id) ELSE 
 								(SELECT 'Representante ' || pjh_razao FROM docwin.pessoa_juridica_historico_tb WHERE old.re_id = pjh_id) END) || ' do participante ' || (SELECT CASE  WHEN pa_tipo = 'F' THEN 
 								(SELECT 'CPF n� ' || lpad(ph_cpf::text, 11,'0') FROM docwin.pessoa_fisica_historico_tb WHERE old.pa_id = ph_id) ELSE 
 								(SELECT 'CNPJ n� ' || lpad(pjh_cnpj::text,15,'0') FROM docwin.pessoa_juridica_historico_tb WHERE old.pa_id = pjh_id) END 
 								 FROM docwin.p_participantes_tb WHERE p_participantes_tb.at_key = old.at_key AND p_participantes_tb.pa_id = old.pa_id))  ,''		,now()        		,user);
 		end if;	
 	end if;
 elseif (quote_ident(TG_relname) = 'p_participantes_rogo_tb') then
 	if ( TG_OP = 'INSERT') then	
 		insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 
 				   (new.at_key   ,'Rogo inserido'      ,quote_ident(TG_relname), ''            ,((SELECT 'Rogo ' || ph_nome FROM docwin.pessoa_fisica_historico_tb WHERE new.pf_id = ph_id)
 								|| ' do participante ' || (SELECT CASE  WHEN pa_tipo = 'F' THEN 
 								(SELECT 'CPF n� ' || lpad(ph_cpf::text, 11,'0') FROM docwin.pessoa_fisica_historico_tb WHERE new.pa_id = ph_id) ELSE 
 								(SELECT 'CNPJ n� ' || lpad(pjh_cnpj::text,15,'0') FROM docwin.pessoa_juridica_historico_tb WHERE new.pa_id = pjh_id) END 
 								 FROM docwin.p_participantes_tb WHERE p_participantes_tb.at_key = new.at_key AND p_participantes_tb.pa_id = new.pa_id))      ,now()            ,user);
 	else 
 		if ( TG_OP = 'DELETE') then
 			insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 
 				 (old.at_key    ,'Rogo excluido'      	,quote_ident(TG_relname), ((SELECT 'Rogo ' || ph_nome FROM docwin.pessoa_fisica_historico_tb WHERE old.re_id = ph_id)  
 								|| ' do participante ' || (SELECT CASE  WHEN pa_tipo = 'F' THEN 
 								(SELECT 'CPF n� ' || lpad(ph_cpf::text, 11,'0') FROM docwin.pessoa_fisica_historico_tb WHERE old.pa_id = ph_id) ELSE 
 								(SELECT 'CNPJ n� ' || lpad(pjh_cnpj::text,15,'0') FROM docwin.pessoa_juridica_historico_tb WHERE old.pa_id = pjh_id) END 
 								 FROM docwin.p_participantes_tb WHERE p_participantes_tb.at_key = old.at_key AND p_participantes_tb.pa_id = old.pa_id))  ,''		,now()        		,user);
 		end if;	
 	end if;
 elseif (quote_ident(TG_relname) = 'p_participantes_testestemunhas_tb') then
 	if ( TG_OP = 'INSERT') then	
 		insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 
 				   (new.at_key   ,'Testemunha inserida'      ,quote_ident(TG_relname), ''            ,((SELECT 'Testemunha ' || ph_nome FROM docwin.pessoa_fisica_historico_tb WHERE new.pf_key = ph_id)
 								|| ' do participante ' || (SELECT CASE  WHEN pa_tipo = 'F' THEN 
 								(SELECT 'CPF n� ' || lpad(ph_cpf::text, 11,'0') FROM docwin.pessoa_fisica_historico_tb WHERE new.pa_id = ph_id) ELSE 
 								(SELECT 'CNPJ n� ' || lpad(pjh_cnpj::text,15,'0') FROM docwin.pessoa_juridica_historico_tb WHERE new.pa_id = pjh_id) END 
 								 FROM docwin.p_participantes_tb WHERE p_participantes_tb.at_key = new.at_key AND p_participantes_tb.pa_id = new.pa_id))      ,now()            ,user);
 	else 
 		if ( TG_OP = 'DELETE') then
 			insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 
 				 (old.at_key    ,'Testemunha excluida'      	,quote_ident(TG_relname), ((SELECT 'Testemunha ' || ph_nome FROM docwin.pessoa_fisica_historico_tb WHERE old.pf_key = ph_id)  
 								|| ' do participante ' || (SELECT CASE  WHEN pa_tipo = 'F' THEN 
 								(SELECT 'CPF n� ' || lpad(ph_cpf::text, 11,'0') FROM docwin.pessoa_fisica_historico_tb WHERE old.pa_id = ph_id) ELSE 
 								(SELECT 'CNPJ n� ' || lpad(pjh_cnpj::text,15,'0') FROM docwin.pessoa_juridica_historico_tb WHERE old.pa_id = pjh_id) END 
 								 FROM docwin.p_participantes_tb WHERE p_participantes_tb.at_key = old.at_key AND p_participantes_tb.pa_id = old.pa_id))  ,''		,now()        		,user);
 		end if;	
 	end if;
 elseif (quote_ident(TG_relname) = 'p_atos_poderes_tb' or quote_ident(TG_relname) = 'p_atos_poderes_campos_variaveis_tb') then
 	if ( TG_OP = 'INSERT') then	
 		insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 
 				   (new.at_key   ,'Poder inserido'      ,quote_ident(TG_relname), ''            ,(SELECT 'Poder ' || po_titulo FROM docwin.p_poderes_tb WHERE new.po_key = po_key)
 								      ,now()            ,user);
 	else 
 		if ( TG_OP = 'DELETE') then
 			insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 
 				 (old.at_key    ,'Poder excluido'      	,quote_ident(TG_relname), (SELECT 'Poder ' || po_titulo FROM docwin.p_poderes_tb WHERE old.po_key = po_key)  
 								  ,''		,now()        		,user);
 		end if;	
 	end if;
 
     FOR ri IN
         SELECT  column_name
         FROM information_schema.columns
         WHERE
             table_schema = quote_ident(TG_TABLE_SCHEMA)
         AND table_name = quote_ident(TG_TABLE_NAME)
         ORDER BY ordinal_position
     LOOP
 	if ( TG_OP = 'UPDATE') then		
 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_antigo using old;
 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_novo using NEW;
 		if campo_novo <> campo_antigo then
 			insert into docwin.p_log_modificacoes_tb (id      , campo_modificado, tabela                , valor_anterior  , valor_posterior, data_modificacao, usuario) values 
 				        (old.at_key  ,ri.column_name || ' ' || (SELECT ' do poder ' || po_titulo FROM docwin.p_poderes_tb WHERE old.po_key = po_key)   || ' do ato ' || (SELECT 'Livro ' || p_atos_tb.at_livronome::text || '-' || (CASE WHEN p_atos_tb.at_livronumero < 0 THEN '*' ELSE at_livronumero::text END) 
 			|| ', Pag. ini. '  || (CASE WHEN at_folhanumero < 0 THEN '*' ELSE at_folhanumero::text END) 
 			|| ' e Pag. final. '  || (CASE WHEN at_folhanumerofinal < 0 THEN '*' ELSE at_folhanumerofinal::text END)
 				FROM docwin.p_atos_tb WHERE at_key=old.at_key)   ,quote_ident(TG_relname), campo_antigo    ,campo_novo      ,now()      ,user);
                 end if;
         end if;       
     END LOOP;
     RETURN NEW;
 
 elseif (quote_ident(TG_relname) = 'p_testetmunhas_ato') then
 	if ( TG_OP = 'INSERT') then	
 		insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 
 				   (new.at_key   ,'Testemunha do ato inserida'      ,quote_ident(TG_relname), ''            ,(SELECT 'Testemunha ' || ph_nome FROM docwin.pessoa_fisica_historico_tb WHERE new.pf_id = ph_id)      ,now()            ,user);
 	else 
 		if ( TG_OP = 'DELETE') then
 			insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 
 				 (old.at_key    ,'Testemunha do ato excluida'      	,quote_ident(TG_relname), (SELECT 'Testemunha ' || ph_nome FROM docwin.pessoa_fisica_historico_tb WHERE old.pf_id = ph_id)  ,''		,now()        		,user);
 		end if;	
 	end if;
 
 elseif (quote_ident(TG_relname) = 'p_vadi_tb') then
 	if ( TG_OP = 'INSERT') then	
 		insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 
 				   (new.va_link   ,'Var. Adicional do ato inserida'      ,quote_ident(TG_relname), ''            ,(SELECT 'Var. Adicional ' || ad_tit FROM docwin.p_adic_tb  WHERE new.va_codi = ad_cod)      ,now()            ,user);
 	else 
 		if ( TG_OP = 'DELETE') then
 			insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 
 				 (old.va_link    ,'Var. Adicional do ato excluida'      	,quote_ident(TG_relname), (SELECT 'Var. Adicional ' || ad_tit FROM  docwin.p_adic_tb WHERE old.va_codi = ad_cod)  ,''		,now()        		,user);
 		end if;	
 	end if;
 
     FOR ri IN

         SELECT  column_name

         FROM information_schema.columns

         WHERE

             table_schema = quote_ident(TG_TABLE_SCHEMA)

         AND table_name = quote_ident(TG_TABLE_NAME)

         ORDER BY ordinal_position

     LOOP

 	if ( TG_OP = 'UPDATE') then		

 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_antigo using old;

 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_novo using NEW;

 		if campo_novo <> campo_antigo then

 			insert into docwin.p_log_modificacoes_tb (id      , campo_modificado, tabela                , valor_anterior  , valor_posterior, data_modificacao, usuario) values 

 				        (old.va_link  ,ri.column_name || ' ' || (SELECT 'Var. Adicional ' || ad_tit FROM  docwin.p_adic_tb WHERE old.va_codi = ad_cod) || ' do ato ' || (SELECT 'Livro ' || at_livronome::text || '-' || (CASE WHEN at_livronumero < 0 THEN '*' ELSE at_livronumero::text END) 

 			|| ', Pag. ini. '  || (CASE WHEN at_folhanumero < 0 THEN '*' ELSE at_folhanumero::text END) 

 			|| ' e Pag. final. '  || (CASE WHEN at_folhanumerofinal < 0 THEN '*' ELSE at_folhanumerofinal::text END)

 				FROM docwin.p_atos_tb WHERE at_key=old.va_link)   ,quote_ident(TG_relname), campo_antigo    ,campo_novo      ,now()      ,user);

                 end if;

         end if;       

     END LOOP;

     RETURN NEW;

 

 

 elseif (quote_ident(TG_relname) = 'p_atos_cobrancas_tb') then

 	if ( TG_OP = 'INSERT') then	

 		insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 

 				   (new.at_key   ,'Cobrança do ato inserida'      ,quote_ident(TG_relname), ''            ,(SELECT 'Cobrança ' || descricao FROM docwin.u_ato_padronizado_tb  WHERE new.co_key = id)      ,now()            ,user);

 	else 

 		if ( TG_OP = 'DELETE') then

 			insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 

 				 (old.at_key    ,'Cobranca do ato excluida'      	,quote_ident(TG_relname), (SELECT 'Cobranca ' || descricao FROM  docwin.u_ato_padronizado_tb WHERE old.co_key = id) || CASE WHEN old.ac_ordem > 0 THEN ' vinculada a OS ' || old.ac_ordem ELSE '' END  ,''		,now()        		,user);

 		end if;	

 	end if;

 

     FOR ri IN

         SELECT  column_name

         FROM information_schema.columns

         WHERE

             table_schema = quote_ident(TG_TABLE_SCHEMA)

         AND table_name = quote_ident(TG_TABLE_NAME)

         ORDER BY ordinal_position

     LOOP

 	if ( TG_OP = 'UPDATE') then		

 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_antigo using old;

 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_novo using NEW;

 		if campo_novo <> campo_antigo then

 			insert into docwin.p_log_modificacoes_tb (id      , campo_modificado, tabela                , valor_anterior  , valor_posterior, data_modificacao, usuario) values 

 				        (old.at_key  ,ri.column_name || ' ' || (SELECT 'Cobranca ' || descricao FROM  docwin.u_ato_padronizado_tb WHERE old.co_key = id) || ' do ato ' || (SELECT 'Livro ' || at_livronome::text || '-' || (CASE WHEN at_livronumero < 0 THEN '*' ELSE at_livronumero::text END) 

 			|| ', Pag. ini. '  || (CASE WHEN at_folhanumero < 0 THEN '*' ELSE at_folhanumero::text END) 

 			|| ' e Pag. final. '  || (CASE WHEN at_folhanumerofinal < 0 THEN '*' ELSE at_folhanumerofinal::text END)

 				FROM docwin.p_atos_tb WHERE at_key=old.at_key)   ,quote_ident(TG_relname), campo_antigo    ,campo_novo      ,now()      ,user);

                 end if;

         end if;       

     END LOOP;

     RETURN NEW;

 

 

 

 elseif (quote_ident(TG_relname) = 'p_atos_assentamentos_tb') then

 	if ( TG_OP = 'INSERT') then	

 		insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 

 				   (new.va_link   ,'Assentamento do ato inserida'      ,quote_ident(TG_relname), ''            ,'Assentamento ' || new.aa_titulo     ,now()            ,user);

 	else 

 		if ( TG_OP = 'DELETE') then

 			insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 

 				 (old.va_link    ,'Assentamento do ato excluida'      	,quote_ident(TG_relname),'Assentamento ' || old.aa_titulo,''		,now()        		,user);

 		end if;	

 	end if;

 

     FOR ri IN

         SELECT  column_name

         FROM information_schema.columns

         WHERE

             table_schema = quote_ident(TG_TABLE_SCHEMA)

         AND table_name = quote_ident(TG_TABLE_NAME)

         ORDER BY ordinal_position

     LOOP

 	if ( TG_OP = 'UPDATE') then		

 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_antigo using old;

 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_novo using NEW;

 		if campo_novo <> campo_antigo then

 			insert into docwin.p_log_modificacoes_tb (id      , campo_modificado, tabela                , valor_anterior  , valor_posterior, data_modificacao, usuario) values 

 				        (old.va_link  ,ri.column_name || ' ' || 'Assentamento ' || old.aa_titulo || ' do ato ' || (SELECT 'Livro ' || at_livronome::text || '-' || (CASE WHEN at_livronumero < 0 THEN '*' ELSE at_livronumero::text END) 

 			|| ', Pag. ini. '  || (CASE WHEN at_folhanumero < 0 THEN '*' ELSE at_folhanumero::text END) 

 			|| ' e Pag. final. '  || (CASE WHEN at_folhanumerofinal < 0 THEN '*' ELSE at_folhanumerofinal::text END)

 				FROM docwin.p_atos_tb WHERE at_key=old.at_key)   ,quote_ident(TG_relname), campo_antigo    ,campo_novo      ,now()      ,user);

                 end if;

         end if;       

     END LOOP;

     RETURN NEW;

 

 

 else

 	if ( TG_OP = 'INSERT') then	

 		insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 

 				   (new.at_key ,  'Ato inserido (' || new.at_key::text ||')' ,quote_ident(TG_relname)      , ''            ,'Ato inserido'       ,now()            ,user);

 	else 

 		 if ( TG_OP = 'DELETE') then

 			insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 

 					 (old.at_key    ,'Ato excluido (' || new.at_key::text ||')', quote_ident(TG_relname), 'Livro ' || old.at_livronome::text || '-' || (CASE WHEN old.at_livronumero < 0 THEN '*' ELSE old.at_livronumero::text END) 

 			|| ', Pag. ini. '  || (CASE WHEN old.at_folhanumero < 0 THEN '*' ELSE old.at_folhanumero::text END) 

 			|| ' e Pag. final. '  || (CASE WHEN old.at_folhanumerofinal < 0 THEN '*' ELSE old.at_folhanumerofinal::text END),''  		,now()        		,user);

 		 end if;	

     end if;

 end if;

     FOR ri IN

         SELECT  column_name

         FROM information_schema.columns

         WHERE

             table_schema = quote_ident(TG_TABLE_SCHEMA)

         AND table_name = quote_ident(TG_TABLE_NAME)

         ORDER BY ordinal_position

     LOOP

 	if ( TG_OP = 'UPDATE') then		

 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_antigo using old;

 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_novo using NEW;

 		if campo_novo <> campo_antigo then

 			insert into docwin.p_log_modificacoes_tb (id      , campo_modificado, tabela                , valor_anterior  , valor_posterior, data_modificacao, usuario) values 

 				        (old.at_key  ,ri.column_name || ' do ato ' || (SELECT 'Livro ' || at_livronome::text || '-' || (CASE WHEN at_livronumero < 0 THEN '*' ELSE at_livronumero::text END) 

 			|| ', Pag. ini. '  || (CASE WHEN at_folhanumero < 0 THEN '*' ELSE at_folhanumero::text END) 

 			|| ' e Pag. final. '  || (CASE WHEN at_folhanumerofinal < 0 THEN '*' ELSE at_folhanumerofinal::text END)

 				FROM docwin.p_atos_tb WHERE at_key=old.at_key)   ,quote_ident(TG_relname), campo_antigo    ,campo_novo      ,now()      ,user);

                 end if;

         end if;       

     END LOOP;

     RETURN NEW;

 END;

  $BODY$

  LANGUAGE plpgsql VOLATILE

  COST 100;

ALTER FUNCTION docwin.log_p_ato_tb()

  OWNER TO postgres;

GRANT EXECUTE ON FUNCTION docwin.log_p_ato_tb() TO postgres;

GRANT EXECUTE ON FUNCTION docwin.log_p_ato_tb() TO public;

GRANT EXECUTE ON FUNCTION docwin.log_p_ato_tb() TO docwin_owner;

GRANT EXECUTE ON FUNCTION docwin.log_p_ato_tb() TO escreventes;

GRANT EXECUTE ON FUNCTION docwin.log_p_ato_tb() TO supervisores;


-- 0.70


SET client_min_messages TO ERROR;

-- Function: docwin.log_p_ato_tb()

-- DROP FUNCTION docwin.log_p_ato_tb();

-- Function: docwin.log_p_ato_tb()

-- DROP FUNCTION docwin.log_p_ato_tb();

CREATE OR REPLACE FUNCTION docwin.log_p_ato_tb()
  RETURNS trigger AS
$BODY$ 
 DECLARE
     ri RECORD;
     campo_novo TEXT;
     campo_antigo text;
 BEGIN
 	
  if (quote_ident(TG_relname) = 'p_participantes_tb') then
 	if ( TG_OP = 'INSERT') then	
 		insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 
 				   (new.at_key   ,'Participante inserido'      ,quote_ident(TG_relname), ''            ,(SELECT CASE  WHEN new.pa_tipo = 'F' THEN 
 								(SELECT 'CPF n� ' || lpad(ph_cpf::text, 11,'0') FROM docwin.pessoa_fisica_historico_tb WHERE new.pa_id = ph_id) ELSE 
 								(SELECT 'CNPJ n� ' || lpad(pjh_cnpj::text,15,'0') FROM docwin.pessoa_juridica_historico_tb WHERE new.pa_id = pjh_id) END)      ,now()            ,user);
 	else 
 		if ( TG_OP = 'DELETE') then
 			insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 
 				 (old.at_key    ,'Participante excluído'      	,quote_ident(TG_relname), (SELECT CASE  WHEN old.pa_tipo = 'F' THEN 
 								(SELECT 'CPF n� ' || lpad(ph_cpf::text, 11,'0') FROM docwin.pessoa_fisica_historico_tb WHERE old.pa_id = ph_id) ELSE 
 								(SELECT 'CNPJ n� ' || lpad(pjh_cnpj::text,15,'0') FROM docwin.pessoa_juridica_historico_tb WHERE old.pa_id = pjh_id) END)  ,''		,now()        		,user);
 		end if;	
 	end if;
 
     FOR ri IN
         SELECT  column_name
         FROM information_schema.columns
         WHERE
             table_schema = quote_ident(TG_TABLE_SCHEMA)
         AND table_name = quote_ident(TG_TABLE_NAME)
         ORDER BY ordinal_position
     LOOP
 	if ( TG_OP = 'UPDATE') then		
 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_antigo using old;
 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_novo using NEW;
 		if campo_novo <> campo_antigo then
 			insert into docwin.p_log_modificacoes_tb (id      , campo_modificado, tabela                , valor_anterior  , valor_posterior, data_modificacao, usuario) values 
 				        (old.at_key  ,ri.column_name || ' do participante ' ||  (SELECT CASE  WHEN old.pa_tipo = 'F' THEN 
 								(SELECT 'CPF n� ' || lpad(ph_cpf::text, 11,'0') FROM docwin.pessoa_fisica_historico_tb WHERE old.pa_id = ph_id) ELSE 
 								(SELECT 'CNPJ n� ' || lpad(pjh_cnpj::text,15,'0') FROM docwin.pessoa_juridica_historico_tb WHERE old.pa_id = pjh_id) END)   || ' do ato ' || (SELECT 'Livro ' || at_livronome::text || '-' || (CASE WHEN at_livronumero < 0 THEN '*' ELSE at_livronumero::text END) 
 			|| ', Pag. ini. '  || (CASE WHEN at_folhanumero < 0 THEN '*' ELSE at_folhanumero::text END) 
 			|| ' e Pag. final. '  || (CASE WHEN at_folhanumerofinal < 0 THEN '*' ELSE at_folhanumerofinal::text END)
 				FROM docwin.p_atos_tb WHERE at_key=old.at_key)   ,quote_ident(TG_relname), campo_antigo    ,campo_novo      ,now()      ,user);
                 end if;
         end if;       
     END LOOP;
     RETURN NEW;
 
 elseif (quote_ident(TG_relname) = 'p_participantes_representantes_tb') then
 	if ( TG_OP = 'INSERT') then	
 		insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 
 				   (new.at_key   ,'Representante inserido'      ,quote_ident(TG_relname), ''            ,((SELECT CASE  WHEN new.re_tipo = 'F' THEN 
 								(SELECT 'Representante ' || ph_nome FROM docwin.pessoa_fisica_historico_tb WHERE new.re_id = ph_id) ELSE 
 								(SELECT 'Representante ' || pjh_razao FROM docwin.pessoa_juridica_historico_tb WHERE new.re_id = pjh_id) END) || ' do participante ' || (SELECT CASE  WHEN pa_tipo = 'F' THEN 
 								(SELECT 'CPF n� ' || lpad(ph_cpf::text, 11,'0') FROM docwin.pessoa_fisica_historico_tb WHERE new.pa_id = ph_id) ELSE 
 								(SELECT 'CNPJ n� ' || lpad(pjh_cnpj::text,15,'0') FROM docwin.pessoa_juridica_historico_tb WHERE new.pa_id = pjh_id) END 
 								 FROM docwin.p_participantes_tb WHERE p_participantes_tb.at_key = new.at_key AND p_participantes_tb.pa_id = new.pa_id))      ,now()            ,user);
 	else 
 		if ( TG_OP = 'DELETE') then
 			insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 
 				 (old.at_key    ,'Representante excluído'      	,quote_ident(TG_relname), ((SELECT CASE  WHEN old.re_tipo = 'F' THEN 
 								(SELECT 'Representante ' || ph_nome FROM docwin.pessoa_fisica_historico_tb WHERE old.re_id = ph_id) ELSE 
 								(SELECT 'Representante ' || pjh_razao FROM docwin.pessoa_juridica_historico_tb WHERE old.re_id = pjh_id) END) || ' do participante ' || (SELECT CASE  WHEN pa_tipo = 'F' THEN 
 								(SELECT 'CPF n� ' || lpad(ph_cpf::text, 11,'0') FROM docwin.pessoa_fisica_historico_tb WHERE old.pa_id = ph_id) ELSE 
 								(SELECT 'CNPJ n� ' || lpad(pjh_cnpj::text,15,'0') FROM docwin.pessoa_juridica_historico_tb WHERE old.pa_id = pjh_id) END 
 								 FROM docwin.p_participantes_tb WHERE p_participantes_tb.at_key = old.at_key AND p_participantes_tb.pa_id = old.pa_id))  ,''		,now()        		,user);
 		end if;	
 	end if;
 elseif (quote_ident(TG_relname) = 'p_participantes_rogo_tb') then
 	if ( TG_OP = 'INSERT') then	
 		insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 
 				   (new.at_key   ,'Rogo inserido'      ,quote_ident(TG_relname), ''            ,((SELECT 'Rogo ' || ph_nome FROM docwin.pessoa_fisica_historico_tb WHERE new.pf_id = ph_id)
 								|| ' do participante ' || (SELECT CASE  WHEN pa_tipo = 'F' THEN 
 								(SELECT 'CPF n� ' || lpad(ph_cpf::text, 11,'0') FROM docwin.pessoa_fisica_historico_tb WHERE new.pa_id = ph_id) ELSE 
 								(SELECT 'CNPJ n� ' || lpad(pjh_cnpj::text,15,'0') FROM docwin.pessoa_juridica_historico_tb WHERE new.pa_id = pjh_id) END 
 								 FROM docwin.p_participantes_tb WHERE p_participantes_tb.at_key = new.at_key AND p_participantes_tb.pa_id = new.pa_id))      ,now()            ,user);
 	else 
 		if ( TG_OP = 'DELETE') then
 			insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 
 				 (old.at_key    ,'Rogo excluido'      	,quote_ident(TG_relname), ((SELECT 'Rogo ' || ph_nome FROM docwin.pessoa_fisica_historico_tb WHERE old.re_id = ph_id)  
 								|| ' do participante ' || (SELECT CASE  WHEN pa_tipo = 'F' THEN 
 								(SELECT 'CPF n� ' || lpad(ph_cpf::text, 11,'0') FROM docwin.pessoa_fisica_historico_tb WHERE old.pa_id = ph_id) ELSE 
 								(SELECT 'CNPJ n� ' || lpad(pjh_cnpj::text,15,'0') FROM docwin.pessoa_juridica_historico_tb WHERE old.pa_id = pjh_id) END 
 								 FROM docwin.p_participantes_tb WHERE p_participantes_tb.at_key = old.at_key AND p_participantes_tb.pa_id = old.pa_id))  ,''		,now()        		,user);
 		end if;	
 	end if;
 elseif (quote_ident(TG_relname) = 'p_participantes_testestemunhas_tb') then
 	if ( TG_OP = 'INSERT') then	
 		insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 
 				   (new.at_key   ,'Testemunha inserida'      ,quote_ident(TG_relname), ''            ,((SELECT 'Testemunha ' || ph_nome FROM docwin.pessoa_fisica_historico_tb WHERE new.pf_key = ph_id)
 								|| ' do participante ' || (SELECT CASE  WHEN pa_tipo = 'F' THEN 
 								(SELECT 'CPF n� ' || lpad(ph_cpf::text, 11,'0') FROM docwin.pessoa_fisica_historico_tb WHERE new.pa_id = ph_id) ELSE 
 								(SELECT 'CNPJ n� ' || lpad(pjh_cnpj::text,15,'0') FROM docwin.pessoa_juridica_historico_tb WHERE new.pa_id = pjh_id) END 
 								 FROM docwin.p_participantes_tb WHERE p_participantes_tb.at_key = new.at_key AND p_participantes_tb.pa_id = new.pa_id))      ,now()            ,user);
 	else 
 		if ( TG_OP = 'DELETE') then
 			insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 
 				 (old.at_key    ,'Testemunha excluida'      	,quote_ident(TG_relname), ((SELECT 'Testemunha ' || ph_nome FROM docwin.pessoa_fisica_historico_tb WHERE old.pf_key = ph_id)  
 								|| ' do participante ' || (SELECT CASE  WHEN pa_tipo = 'F' THEN 
 								(SELECT 'CPF n� ' || lpad(ph_cpf::text, 11,'0') FROM docwin.pessoa_fisica_historico_tb WHERE old.pa_id = ph_id) ELSE 
 								(SELECT 'CNPJ n� ' || lpad(pjh_cnpj::text,15,'0') FROM docwin.pessoa_juridica_historico_tb WHERE old.pa_id = pjh_id) END 
 								 FROM docwin.p_participantes_tb WHERE p_participantes_tb.at_key = old.at_key AND p_participantes_tb.pa_id = old.pa_id))  ,''		,now()        		,user);
 		end if;	
 	end if;
 elseif (quote_ident(TG_relname) = 'p_atos_poderes_tb' or quote_ident(TG_relname) = 'p_atos_poderes_campos_variaveis_tb') then
 	if ( TG_OP = 'INSERT') then	
 		insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 
 				   (new.at_key   ,'Poder inserido'      ,quote_ident(TG_relname), ''            ,(SELECT 'Poder ' || po_titulo FROM docwin.p_poderes_tb WHERE new.po_key = po_key)
 								      ,now()            ,user);
 	else 
 		if ( TG_OP = 'DELETE') then
 			insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 
 				 (old.at_key    ,'Poder excluido'      	,quote_ident(TG_relname), (SELECT 'Poder ' || po_titulo FROM docwin.p_poderes_tb WHERE old.po_key = po_key)  
 								  ,''		,now()        		,user);
 		end if;	
 	end if;
 
     FOR ri IN
         SELECT  column_name
         FROM information_schema.columns
         WHERE
             table_schema = quote_ident(TG_TABLE_SCHEMA)
         AND table_name = quote_ident(TG_TABLE_NAME)
         ORDER BY ordinal_position
     LOOP
 	if ( TG_OP = 'UPDATE') then		
 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_antigo using old;
 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_novo using NEW;
 		if campo_novo <> campo_antigo then
 			insert into docwin.p_log_modificacoes_tb (id      , campo_modificado, tabela                , valor_anterior  , valor_posterior, data_modificacao, usuario) values 
 				        (old.at_key  ,ri.column_name || ' ' || (SELECT ' do poder ' || po_titulo FROM docwin.p_poderes_tb WHERE old.po_key = po_key)   || ' do ato ' || (SELECT 'Livro ' || p_atos_tb.at_livronome::text || '-' || (CASE WHEN p_atos_tb.at_livronumero < 0 THEN '*' ELSE at_livronumero::text END) 
 			|| ', Pag. ini. '  || (CASE WHEN at_folhanumero < 0 THEN '*' ELSE at_folhanumero::text END) 
 			|| ' e Pag. final. '  || (CASE WHEN at_folhanumerofinal < 0 THEN '*' ELSE at_folhanumerofinal::text END)
 				FROM docwin.p_atos_tb WHERE at_key=old.at_key)   ,quote_ident(TG_relname), campo_antigo    ,campo_novo      ,now()      ,user);
                 end if;
         end if;       
     END LOOP;
     RETURN NEW;
 
 elseif (quote_ident(TG_relname) = 'p_testetmunhas_ato') then
 	if ( TG_OP = 'INSERT') then	
 		insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 
 				   (new.at_key   ,'Testemunha do ato inserida'      ,quote_ident(TG_relname), ''            ,(SELECT 'Testemunha ' || ph_nome FROM docwin.pessoa_fisica_historico_tb WHERE new.pf_id = ph_id)      ,now()            ,user);
 	else 
 		if ( TG_OP = 'DELETE') then
 			insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 
 				 (old.at_key    ,'Testemunha do ato excluida'      	,quote_ident(TG_relname), (SELECT 'Testemunha ' || ph_nome FROM docwin.pessoa_fisica_historico_tb WHERE old.pf_id = ph_id)  ,''		,now()        		,user);
 		end if;	
 	end if;
 
 elseif (quote_ident(TG_relname) = 'p_vadi_tb') then
 	if ( TG_OP = 'INSERT') then	
 		insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 
 				   (new.va_link   ,'Var. Adicional do ato inserida'      ,quote_ident(TG_relname), ''            ,(SELECT 'Var. Adicional ' || ad_tit FROM docwin.p_adic_tb  WHERE new.va_codi = ad_cod)      ,now()            ,user);
 	else 
 		if ( TG_OP = 'DELETE') then
 			insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 
 				 (old.va_link    ,'Var. Adicional do ato excluida'      	,quote_ident(TG_relname), (SELECT 'Var. Adicional ' || ad_tit FROM  docwin.p_adic_tb WHERE old.va_codi = ad_cod)  ,''		,now()        		,user);
 		end if;	
 	end if;
 
     FOR ri IN

         SELECT  column_name

         FROM information_schema.columns

         WHERE

             table_schema = quote_ident(TG_TABLE_SCHEMA)

         AND table_name = quote_ident(TG_TABLE_NAME)

         ORDER BY ordinal_position

     LOOP

 	if ( TG_OP = 'UPDATE') then		

 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_antigo using old;

 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_novo using NEW;

 		if campo_novo <> campo_antigo then

 			insert into docwin.p_log_modificacoes_tb (id      , campo_modificado, tabela                , valor_anterior  , valor_posterior, data_modificacao, usuario) values 

 				        (old.va_link  ,ri.column_name || ' ' || (SELECT 'Var. Adicional ' || ad_tit FROM  docwin.p_adic_tb WHERE old.va_codi = ad_cod) || ' do ato ' || (SELECT 'Livro ' || at_livronome::text || '-' || (CASE WHEN at_livronumero < 0 THEN '*' ELSE at_livronumero::text END) 

 			|| ', Pag. ini. '  || (CASE WHEN at_folhanumero < 0 THEN '*' ELSE at_folhanumero::text END) 

 			|| ' e Pag. final. '  || (CASE WHEN at_folhanumerofinal < 0 THEN '*' ELSE at_folhanumerofinal::text END)

 				FROM docwin.p_atos_tb WHERE at_key=old.va_link)   ,quote_ident(TG_relname), campo_antigo    ,campo_novo      ,now()      ,user);

                 end if;

         end if;       

     END LOOP;

     RETURN NEW;

 

 

 elseif (quote_ident(TG_relname) = 'p_atos_cobrancas_tb') then

 	if ( TG_OP = 'INSERT') then	

 		insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 

 				   (new.at_key   ,'Cobrança do ato inserida'      ,quote_ident(TG_relname), ''            ,(SELECT 'Cobrança ' || descricao FROM docwin.u_ato_padronizado_tb  WHERE new.co_key = id)      ,now()            ,user);

 	else 

 		if ( TG_OP = 'DELETE') then

 			insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 

 				 (old.at_key    ,'Cobranca do ato excluida'      	,quote_ident(TG_relname), (SELECT 'Cobranca ' || descricao FROM  docwin.u_ato_padronizado_tb WHERE old.co_key = id) || CASE WHEN old.ac_ordem > 0 THEN ' vinculada a OS ' || old.ac_ordem ELSE '' END  ,''		,now()        		,user);

 		end if;	

 	end if;

 

     FOR ri IN

         SELECT  column_name

         FROM information_schema.columns

         WHERE

             table_schema = quote_ident(TG_TABLE_SCHEMA)

         AND table_name = quote_ident(TG_TABLE_NAME)

         ORDER BY ordinal_position

     LOOP

 	if ( TG_OP = 'UPDATE') then		

 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_antigo using old;

 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_novo using NEW;

 		if campo_novo <> campo_antigo then

 			insert into docwin.p_log_modificacoes_tb (id      , campo_modificado, tabela                , valor_anterior  , valor_posterior, data_modificacao, usuario) values 

 				        (old.at_key  ,ri.column_name || ' ' || (SELECT 'Cobranca ' || descricao FROM  docwin.u_ato_padronizado_tb WHERE old.co_key = id) || ' do ato ' || (SELECT 'Livro ' || at_livronome::text || '-' || (CASE WHEN at_livronumero < 0 THEN '*' ELSE at_livronumero::text END) 

 			|| ', Pag. ini. '  || (CASE WHEN at_folhanumero < 0 THEN '*' ELSE at_folhanumero::text END) 

 			|| ' e Pag. final. '  || (CASE WHEN at_folhanumerofinal < 0 THEN '*' ELSE at_folhanumerofinal::text END)

 				FROM docwin.p_atos_tb WHERE at_key=old.at_key)   ,quote_ident(TG_relname), campo_antigo    ,campo_novo      ,now()      ,user);

                 end if;

         end if;       

     END LOOP;

     RETURN NEW;

 

 

 

 elseif (quote_ident(TG_relname) = 'p_atos_assentamentos_tb') then

 	if ( TG_OP = 'INSERT') then	

 		insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 

 				   (new.at_key   ,'Assentamento do ato inserida'      ,quote_ident(TG_relname), ''            ,'Assentamento ' || new.aa_titulo     ,now()            ,user);

 	else 

 		if ( TG_OP = 'DELETE') then

 			insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 

 				 (old.at_key    ,'Assentamento do ato excluida'      	,quote_ident(TG_relname),'Assentamento ' || old.aa_titulo,''		,now()        		,user);

 		end if;	

 	end if;

 

     FOR ri IN

         SELECT  column_name

         FROM information_schema.columns

         WHERE

             table_schema = quote_ident(TG_TABLE_SCHEMA)

         AND table_name = quote_ident(TG_TABLE_NAME)

         ORDER BY ordinal_position

     LOOP

 	if ( TG_OP = 'UPDATE') then		

 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_antigo using old;

 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_novo using NEW;

 		if campo_novo <> campo_antigo then

 			insert into docwin.p_log_modificacoes_tb (id      , campo_modificado, tabela                , valor_anterior  , valor_posterior, data_modificacao, usuario) values 

 				        (old.at_key  ,ri.column_name || ' ' || 'Assentamento ' || old.aa_titulo || ' do ato ' || (SELECT 'Livro ' || at_livronome::text || '-' || (CASE WHEN at_livronumero < 0 THEN '*' ELSE at_livronumero::text END) 

 			|| ', Pag. ini. '  || (CASE WHEN at_folhanumero < 0 THEN '*' ELSE at_folhanumero::text END) 

 			|| ' e Pag. final. '  || (CASE WHEN at_folhanumerofinal < 0 THEN '*' ELSE at_folhanumerofinal::text END)

 				FROM docwin.p_atos_tb WHERE at_key=old.at_key)   ,quote_ident(TG_relname), campo_antigo    ,campo_novo      ,now()      ,user);

                 end if;

         end if;       

     END LOOP;

     RETURN NEW;

 

 

 else

 	if ( TG_OP = 'INSERT') then	

 		insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 

 				   (new.at_key ,  'Ato inserido (' || new.at_key::text ||')' ,quote_ident(TG_relname)      , ''            ,'Ato inserido'       ,now()            ,user);

 	else 

 		 if ( TG_OP = 'DELETE') then

 			insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 

 					 (old.at_key    ,'Ato excluido (' || new.at_key::text ||')', quote_ident(TG_relname), 'Livro ' || old.at_livronome::text || '-' || (CASE WHEN old.at_livronumero < 0 THEN '*' ELSE old.at_livronumero::text END) 

 			|| ', Pag. ini. '  || (CASE WHEN old.at_folhanumero < 0 THEN '*' ELSE old.at_folhanumero::text END) 

 			|| ' e Pag. final. '  || (CASE WHEN old.at_folhanumerofinal < 0 THEN '*' ELSE old.at_folhanumerofinal::text END),''  		,now()        		,user);

 		 end if;	

     end if;

 end if;

     FOR ri IN

         SELECT  column_name

         FROM information_schema.columns

         WHERE

             table_schema = quote_ident(TG_TABLE_SCHEMA)

         AND table_name = quote_ident(TG_TABLE_NAME)

         ORDER BY ordinal_position

     LOOP

 	if ( TG_OP = 'UPDATE') then		

 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_antigo using old;

 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_novo using NEW;

 		if campo_novo <> campo_antigo then

 			insert into docwin.p_log_modificacoes_tb (id      , campo_modificado, tabela                , valor_anterior  , valor_posterior, data_modificacao, usuario) values 

 				        (old.at_key  ,ri.column_name || ' do ato ' || (SELECT 'Livro ' || at_livronome::text || '-' || (CASE WHEN at_livronumero < 0 THEN '*' ELSE at_livronumero::text END) 

 			|| ', Pag. ini. '  || (CASE WHEN at_folhanumero < 0 THEN '*' ELSE at_folhanumero::text END) 

 			|| ' e Pag. final. '  || (CASE WHEN at_folhanumerofinal < 0 THEN '*' ELSE at_folhanumerofinal::text END)

 				FROM docwin.p_atos_tb WHERE at_key=old.at_key)   ,quote_ident(TG_relname), campo_antigo    ,campo_novo      ,now()      ,user);

                 end if;

         end if;       

     END LOOP;

     RETURN NEW;

 END;

  $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION docwin.log_p_ato_tb()
  OWNER TO postgres;
GRANT EXECUTE ON FUNCTION docwin.log_p_ato_tb() TO postgres;
GRANT EXECUTE ON FUNCTION docwin.log_p_ato_tb() TO public;
GRANT EXECUTE ON FUNCTION docwin.log_p_ato_tb() TO docwin_owner;
GRANT EXECUTE ON FUNCTION docwin.log_p_ato_tb() TO escreventes;
GRANT EXECUTE ON FUNCTION docwin.log_p_ato_tb() TO supervisores;

 
CREATE OR REPLACE FUNCTION docwin.release_0_7() RETURNS void as
$$
BEGIN

	IF NOT EXISTS(SELECT column_name FROM information_schema.columns WHERE table_schema='docwin' AND table_name='p_poderes_tb' AND column_name='po_statusativo') 
	THEN
		ALTER TABLE docwin.p_poderes_tb
		   ADD COLUMN po_statusativo boolean NOT NULL DEFAULT true;  
	END IF;
	 
	UPDATE docwin.aux_tfun_tb SET tf_perm='IAE' WHERE tf_id=608 or tf_id=610;

	IF NOT EXISTS(SELECT column_name FROM information_schema.columns WHERE table_schema='docwin' AND table_name='p_campos_variaveis_tb' AND column_name='cv_ativo') 
	THEN
		ALTER TABLE docwin.p_campos_variaveis_tb
		   ADD COLUMN cv_ativo boolean NOT NULL DEFAULT true;
	END IF;   
			   
	DROP TRIGGER IF EXISTS "InsertFuncao" ON docwin.p_campos_variaveis_tb;
	DROP TABLE IF EXISTS docwin.p_poderes_campos_variaveis_tb;
	DROP TRIGGER IF EXISTS "UpdateFuncao" ON docwin.p_campos_variaveis_tb;
	
	CREATE TABLE IF NOT EXISTS docwin.p_tipo_poder
		(
		   id serial, 
		   descricao text, 
		   ativo boolean NOT NULL DEFAULT true, 
		   ordem smallint,
		   CONSTRAINT p_tipo_poder_pkey PRIMARY KEY (id)
		) 
		WITH (
		  OIDS = FALSE
		)

		TABLESPACE pg_default;
		ALTER TABLE docwin.p_tipo_poder
		  OWNER TO docwin_owner;
		  
	GRANT ALL ON TABLE docwin.p_tipo_poder TO docwin_owner;
	GRANT ALL ON TABLE docwin.p_tipo_poder TO supervisores;
	GRANT ALL ON TABLE docwin.p_tipo_poder TO escreventes;
	
	IF NOT EXISTS(SELECT * FROM docwin.p_tipo_poder WHERE id=1) 
	THEN
		INSERT INTO docwin.p_tipo_poder VALUES (1, 'Direito da Obriga��es', true, 1);
		INSERT INTO docwin.p_tipo_poder VALUES (2, 'Direito das Coisas', true, 2);
		INSERT INTO docwin.p_tipo_poder VALUES (3, 'Direito Empresarial', true, 3);
		INSERT INTO docwin.p_tipo_poder VALUES (4, 'Direito de Fam�lia', true, 4);
		INSERT INTO docwin.p_tipo_poder VALUES (5, 'Direito das Sucess�es', true, 5);
		INSERT INTO docwin.p_tipo_poder VALUES (6, 'Outras', true, 90);
		INSERT INTO docwin.p_tipo_poder VALUES (7, 'Acervo anterior DeMaria', true, 99);
		PERFORM pg_catalog.setval('docwin.p_tipo_poder_id_seq', (SELECT MAX(ID) FROM docwin.p_tipo_poder ), false);
	END IF;
	
	IF NOT EXISTS(SELECT column_name FROM information_schema.columns WHERE table_schema='docwin' AND table_name='p_poderes_tb' AND column_name='po_tipo') 
	THEN
		ALTER TABLE docwin.p_poderes_tb
			ADD COLUMN po_tipo integer NOT NULL DEFAULT -1;
	END IF;
	

	IF NOT EXISTS(SELECT column_name FROM information_schema.columns WHERE table_schema='docwin' AND table_name='p_poderes_tb' AND column_name='po_descricao') 
	THEN
		ALTER TABLE docwin.p_poderes_tb ADD COLUMN po_descricao text;
	END IF;
		
	IF EXISTS (SELECT * FROM docwin.p_campos_variaveis_tb WHERE cv_key < 1000)
    THEN
		--UPDATE docwin.p_campos_variaveis_tb SET cv_key=cv_key+999;
		PERFORM setval('docwin.p_campos_variaveis_tb_cv_key_seq', (SELECT MAX(cv_key) FROM docwin.p_campos_variaveis_tb), true);
		DELETE FROM docwin.aux_func_tb WHERE fu_mod='P' AND fu_cod>=1000;
	ELSE
		PERFORM setval('docwin.p_campos_variaveis_tb_cv_key_seq', 1000, true);
	END IF;		

    IF NOT EXISTS (SELECT * FROM docwin.aux_func_tb WHERE fu_cod = 634 and fu_mod = 'P')
    THEN
		UPDATE docwin.aux_func_tb SET fu_tit='Informa��o do livro e folhas' WHERE fu_cod = 634 and fu_mod = 'P';
	END IF;
	
	IF NOT EXISTS (SELECT * FROM docwin.aux_func_tb WHERE fu_cod = 627 and fu_mod = 'P')
    THEN
		INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) VALUES (627, 'P', 'Condicional do g�nero/qtde de outorgantes (avalia representantes/assistentes)', 'Fun��o especial. Testa a quantidade e o g�nero de todos os outorgantes levando em conta os representantes/assistentes.', 4, 'F', NULL, NULL, NULL, NULL);
	END IF;
	IF NOT EXISTS (SELECT * FROM docwin.aux_func_tb WHERE fu_cod = 628 and fu_mod = 'P')
    THEN
		INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) VALUES (628, 'P', 'Condicional do g�nero/qtde de outorgados (avalia representantes/assistentes)', 'Fun��o especial. Testa a quantidade e o g�nero de todos os outorgados levando em conta os representantes/assistentes.', 4, 'F', NULL, NULL, NULL, NULL);
	END IF;
	IF EXISTS (SELECT * FROM docwin.aux_func_tb WHERE fu_cod = 601 and fu_mod = 'P')
    THEN
		UPDATE docwin.aux_func_tb SET fu_lnk=4 WHERE fu_cod=601 AND fu_mod='P';
	END IF;
	
END;
$$ LANGUAGE plpgsql VOLATILE;
GRANT EXECUTE ON FUNCTION docwin.release_0_7() TO escreventes;
GRANT EXECUTE ON FUNCTION docwin.release_0_7() TO supervisores;
SELECT docwin.release_0_7();
DROP FUNCTION IF EXISTS docwin.release_0_7();

CREATE OR REPLACE FUNCTION docwin.release_0_7() RETURNS void as
$$
BEGIN

	IF NOT EXISTS(SELECT column_name FROM information_schema.columns WHERE table_schema='docwin' AND table_name='s_entrada_tb' AND column_name='ent_acervorj') 
	THEN
		ALTER TABLE docwin.s_entrada_tb ADD COLUMN ent_acervorj smallint;
	END IF;

END;
$$ LANGUAGE plpgsql VOLATILE;
SELECT docwin.release_0_7();
DROP FUNCTION IF EXISTS docwin.release_0_7();





CREATE OR REPLACE FUNCTION docwin.colunas() RETURNS void as
$$
BEGIN

	IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
                   WHERE table_schema='docwin' AND table_name='u_item_ordem_servico_tb' AND column_name='consolidado' )
    THEN
		ALTER TABLE docwin.u_item_ordem_servico_tb ADD COLUMN consolidado boolean;
    END IF;
	
		IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
                   WHERE table_schema='docwin' AND table_name='u_item_ordem_servico_tb' AND column_name='fechamento_id' )
    THEN
		ALTER TABLE docwin.u_item_ordem_servico_tb ADD COLUMN fechamento_id int;
    END IF;
 
END;
$$ LANGUAGE plpgsql VOLATILE;
GRANT EXECUTE ON FUNCTION docwin.colunas() TO escreventes;
GRANT EXECUTE ON FUNCTION docwin.colunas() TO supervisores;
SELECT docwin.colunas();
DROP FUNCTION IF EXISTS docwin.colunas();


--0.80

SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox1.cmbTipoAto','ato','ato');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox1.cmbTipoAto','

   Ato que esta sendo lavrado:
 
   <b>Procura��o</b>,
   <b>Substabelecimento</b>,
   <b>Ren�ncia</b>,
   <b>Revoga��o</b>.
   ','Ato');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox1.cmbSubstabelecimento','

   Neste campo � informado se poder� 
   ou  n�o ser realizado o substabe-
   lecimento.','Substabelecimento');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.pnlReservaPoderes.cmbReservaPoderes','

   Define-se se haver� reserva de 
   poderes no substabelecimento.','Reserva de poderes');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox1.cmbValidade','

    Define-se  a forma de validade
    do ato que est� sendo lavrado.','Validade');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.pnlDataFinal.txtDataFinal','

   Define-se a data de validade do
   ato que est� sendo lavrado.','Validade');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.pnlAnoMesDias.txtAno','


   Define-se a validade do ato lavrado
   em <b>anos</b>.','Valdiade em anos');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.pnlAnoMesDias.txtM�s','

   Define-se a validade do ato lavrado
   em <b>meses</b>.','Validade em meses');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.pnlAnoMesDias.txtDias','

   Define-se a validade do ato lavrado
   em <b>dias</b>.','Validade em dias');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox1.cmbEmDilig�ncia','

   Define-se a lavratura foi realizada
   em dilig�ncia.

<h>
 
   <b>OBS</b>: Ao informar que <b>SIM</b>, ser� ha-
   bilitado um campo para informar o 
   local da dilig�ncia.
  ','Lavratura em dilig�ncia?');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.pnlLocalDiligencia.txtLocalDiligencia','

   Define-se o local da lavratura do
   ato em dilig�ncia.

<h>

   <b>OBS</b>.: Ao  informar  o CEP do local
   no in�cio do campo o sistema auto-
   maticamente  buscar� o logradouro,
   deixando  o  cursor  na posi��o do
   n�mero a ser preenchido.','Local da dilig�ncia');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.grpDadosAto.cmbLocalLavraturaAtoOriginal','

    Serventia onde foi lavrado o ato
    original.','Serventia');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.grpDadosAto.txtLivroNomeAtoOriginal','


   Nome do livro (caso exista) em que
   foi lavrado o ato original.

   Ex.: para livro <b>P</b>, 
		informar apenas <b>P</b>.','Nome do livro');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.grpDadosAto.txtLivroComplementoAtoOriginal','
  Identifica��o complementar do livro. 
    
  Ex.: para livro n� 100<b>F</b>,
		 informar apenas <b>F</b>.','Complemento do livro');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.grpDadosAto.txtLivroNumeroAtoOriginal','

    N�mero do livro em que foi lavrado
    o ato original.','N�mero do livro');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.grpDadosAto.txtPaginaInicialAtoOriginal','

   P�gina do livro onde foi lavrado o
   ato original.','P�gina inicial do livro');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.grpDadosAto.txtPaginaFinalAtoOriginal','

   P�gina do livro onde foi lavrado o
   ato original.','P�gina final do livro');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.grpDadosAto.txtFolhaComplementoAtoOriginal','
  Identifica��o complementar da folha 

  Ex.: para folha n� 123<b>G</b>,
		informar apenas <b>G</b>.','Complemento da p�gina');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.grpDadosAto.txtDataLavraturaAtoOriginal','

   Data da lavratura do ato original.','Data da lavratura');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.grpDadosAto.cmbPermitiaSubstabelecimentoAtoOriginal','
  
   Define-se se no ato original �
   permitido substabelecimento.','Substabelecimento');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.grpDadosAto.cmbPermitiaRevogacaoAtoOriginal','
   Neste campo � informado se no ato
   original � permitido a revoga��o.
','Revoga��o');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.pnlLocal.txtLocalLavraturaAtoOriginal','

  Nome da serventia em que foi lavrado
  o ato original.	','Nome da serventia');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.pnlLavrou.txtNomeLavrouAtoOriginal','

   Nome do respons�vel pela lavratura
   do ato original.','Nome ');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.pnlArquivo.txtArquivoPastaAtoOriginal','

   Pasta em que se foi realizada os
   arquivamentos   no(a)  serventia
   de lavratura do ato original.','Pasta ');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.pnlArquivo.txtArquivoNumeroAtoOriginal','


   N� da pasta em que se foi realizado 
   os arquivamentos   no(a)  serventia
   de lavratura do ato original.','N� da pasta');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.pnlArquivo.txtArquivoPastaAtoOriginal','

   Pasta em que se foi realizado os
   arquivamentos   no(a)  serventia
   de lavratura do ato original.','Pasta ');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox7.txtCep','


   CEP do logradouro da serventia
   de lavratura do ato original.','CEP');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox7.txtEndereco','


   Logradouro da serventia de lavratura 
   do ato original.','Logradouro');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox7.txtNumero','

   N�mero do logradouro da serventia
   de lavratura do ato original.','N�mero');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox7.txtBairro','

   Bairro do logradouro da serventia
   de lavratura do ato original.','Bairro');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox7.txtCidade','

   Cidade  da serventia de lavratura 
   do ato original.','Cidade');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox7.txtBairro','

   Bairro da serventia de lavratura 
   do ato original.','Bairro');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox7.txtComplemento','

   Complemento do logradouro da serventia
   de lavratura do ato original.','Complemento');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox7.txtPais','

   Pa�s da serventia de lavratura 
   do ato original.','Pa�s');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.pnlLocal.txtLocalLavraturaAtoOriginal','

  Nome do local em que foi lavrado
  o ato original.	


','Nome da serventia/Unidade consular');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox12.cmbTipoLivro','

   Selecione o livro em que est� sendo
   lavrado o ato.

 <h>

   <b>OBS</b>.: A configura��o do livro pode
   ser alterada no menu:

   Procura��es > 
	Configura��es >
		Numera��o Autom�tica','Livro');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox12.txtLivroNome','


   Nome do livro (caso exista) em que
   est� ser� lavrado.

   Ex.: para livro <b>P</b>, 
		informar apenas <b>P</b>.','Livro');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox12.txtLivroComplemento','
  Identifica��o complementar do livro. 
    
  Ex.: para livro n� 100<b>F</b>,
		 informar apenas <b>F</b>.','Complemento do livro');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox12.txtLivroNumero','

   N�mero do livro em que ser� lavrado.','N�mero do livro');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox12.txtPaginaNumero','

   P�gina do livro onde ser� lavrado.','P�gina inicial');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox12.txtPaginaNumeroFinal','
  

   P�gina do livro onde ser� lavrado.','P�gina final');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox12.txtPaginaComplemento','
  Identifica��o complementar da folha 

  Ex.: para folha n� 123<b>G</b>,
		informar apenas <b>G</b>.','Complemento da p�gina');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox12.txtDataAto','


   Data de lavratura do ato.','Data de lavratura');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox12.cmbStatus','
		
   Status do ato lavrado.','Status do ato');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmAssentamentoTexto.panel1.txtNomeServentia','

  Nome  da  serventia onde foi lavrado
  o ato que deu origem a esta anota��o','Nome da serventia');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmAssentamentoTexto.panel1.txtLivro','

  N�mero  do  livro  onde  foi lavrado
  o ato que deu origem a esta anota��o','N�mero do livro');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmAssentamentoTexto.panel1.txtFolhas','


   N�mero  da  folha onde  foi lavrado
  o ato que deu origem a esta anota��o','Folha');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmAssentamentoTexto.panel1.txtDataAto','

   Data de lavratura do ato que deu 
   origem a esta anota��o.','Data de lavratura');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmAssentamentoTexto.panel1.txtPasta','

   Pasta  em  que  foi arquivado na 
   serventia  em  que foi lavrado o
   ato que deu origem a esta anota-
   ��o.','Pasta');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmAssentamentoTexto.panel1.txtArquivo','	

 
   Arquivo em que  foi arquivado na 
   serventia  em  que foi lavrado o
   ato que deu origem a esta anota-
   ��o.','Arquivo');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmAssentamentoTexto.panel1.cmbReservaPoderes','

  Informar neste campo se h� reserva de
  poderes  no ato que deu origem a esta
  anota��o.','Com reserva de poderes?');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmAssentamentoTexto.panel1.cmbAssinantes','

   Assinante desta anota��o.','Assinante');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmPoderes.groupBox2.txtCodigo','

   C�digo para facilitar identifica��o
   no momento da inclus�o no ato.','C�digo do poder');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmPoderes.groupBox2.cmbAtos','

  Qual ato poder� utilizar este poder.','Atos');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmPoderes.groupBox2.txtTitulo','

   T�tulo deste poder. Ser� exibido 
   na  lista  de sele��o na tela de
   inclus�o no ato.
','T�tulo');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmPoderes.groupBox2.cmbTipo','

  Utilizado para organizar e facilitar
  as  buscas  pelo poder no momento de
  incluir no ato.','Tipo');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmPoderes.groupBox3.txtDescricao','

  Orienta��es para a utiliza��o deste
  poder.','Orienta��es');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmPoderes.grdDescricaoPoder.ttcMinuta','

  Texto com a minuta do poder.

<h>

  <b>OBS.</b>: No rodape desta tela � exibido
  os  atalhos para inclus�o de fun��es
  e campos vari�vies.','Minuta do poder');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmCamposVariaveis.groupBox3.txtTitulo','

  Esta informa��o vir� a frente do
  campo para preenchimento.','Campo');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmCamposVariaveis.groupBox3.txtDescricao','

  Descri��o do campo vari�vel.','Descri��o');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmCamposVariaveis.panelCampoTexto.txtMask','

  Neste campo voc� define a m�scara de 
  formata��o para o campo.

  Pode-se utilizar:

  ','M�scara de formata��o');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmCamposVariaveis.panelCampoTexto.txtMask','

  Neste campo voc� define a m�scara de 
  formata��o para o campo.

  Pode-se utilizar:

  <b>0 ou 9</b> para d�gitos num�ricos.
  <b>L ou ?</b> para d�gitos letras.
  <b>A ou a</b> para d�gitos alfanum�ricos.
       <b>></b> para converter d�gitos para
	 mai�sculo.
       <b><</b> para converter d�gitos para
         min�sculo.

  <b>Exemplos de mascaras:</b>

  Placa de ve�culo: 	>LLL-9999
  Data:			99/99/9999
  Hora:			99:99
  CPF 			999\.999\.999-99

  <b>OBS.</b>: Quando se utilizar ponto (.)  na
  m�scara  deve-se  colocar   antes  uma  
  barra (\) como no exemplo do CPF. Isto
  se faz necess�rio pois dependendo das 
  configura��es do sistema operacional, 
  quando   n�o  utiliza-se  a  barra, � 
  trocado o ponto (.) por v�rgula (,).

  ','M�scara de formata��o');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmTipoPoder.grdJustificativa.txtDocumento','

   Descri��o do tipo de poder.','Descri��o');


--Script Iverson
CREATE OR REPLACE FUNCTION docwin.item_selo_os() RETURNS void as
$$
BEGIN
	IF EXISTS (SELECT column_name FROM information_schema.columns WHERE table_schema='docwin' AND table_name='u_selo_item_os_tb' AND column_name='id' )
	THEN
	
	     --EXCLUINDO OS REGISTROS DUPLICADOS - by Pedro
	       DELETE   FROM docwin.u_selo_item_os_tb
           WHERE id NOT IN (SELECT min(id) FROM docwin.u_selo_item_os_tb GROUP BY id_item,sai_key,item);

		   
		   
		ALTER TABLE docwin.u_selo_item_os_tb DROP CONSTRAINT u_selo_item_os_tb_pkey;
		--ALTER TABLE docwin.u_selo_item_os_tb DROP COLUMN id;
		ALTER TABLE docwin.u_selo_item_os_tb ADD CONSTRAINT u_selo_item_os_tb_pkey PRIMARY KEY (id_item, sai_key, item);
		ALTER TABLE docwin.u_selo_item_os_tb DROP CONSTRAINT u_selo_item_os_fkey;
		ALTER TABLE docwin.u_selo_item_os_tb ADD CONSTRAINT u_selo_item_os_fkey FOREIGN KEY (sai_key) REFERENCES docwin.s_saida_tb (sai_key) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT;
	
	
	END IF;
END;
$$ LANGUAGE plpgsql VOLATILE;
SELECT docwin.item_selo_os();
DROP FUNCTION IF EXISTS docwin.item_selo_os();	


CREATE OR REPLACE FUNCTION docwin.colunas() RETURNS void as
$$
BEGIN
	IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
                   WHERE table_schema='docwin' AND table_name='u_item_ato_padronizado_tb' AND column_name='vincula_os' )
    THEN
		ALTER TABLE docwin.u_item_ato_padronizado_tb ADD COLUMN vincula_os boolean DEFAULT true;
    END IF;
END;
$$ LANGUAGE plpgsql VOLATILE;
SELECT docwin.colunas();
DROP FUNCTION IF EXISTS docwin.colunas();



--Script Gustavo
SET client_min_messages TO ERROR;
 
CREATE OR REPLACE FUNCTION docwin.release_0_8() RETURNS void as
$$
BEGIN

	IF NOT EXISTS(SELECT column_name FROM information_schema.columns WHERE table_schema='docwin' AND table_name='v_averb_minutas_tb' AND column_name='av_ativo') 
	THEN
		ALTER TABLE docwin.v_averb_minutas_tb
			ADD COLUMN av_ativo boolean NOT NULL DEFAULT true;

	END IF;	 
	
	UPDATE docwin.aux_tfun_tb SET tf_perm='IAE' WHERE tf_id=504;
	
	
	CREATE TABLE IF NOT EXISTS docwin.e_socios_inter_comer_tb
	(
		  pr_key integer NOT NULL,
		  hp_key bigint NOT NULL,
		  tipo_pessoa "char",
		  CONSTRAINT e_socios_inter_comer_tb_key PRIMARY KEY (pr_key, hp_key),
		  CONSTRAINT e_socios_inter_comer_tb_e_print_tb_fkey FOREIGN KEY (pr_key)
			  REFERENCES docwin.e_prin_tb (pr_key) MATCH SIMPLE
			  ON UPDATE NO ACTION ON DELETE NO ACTION
	)
	WITH (
	  OIDS=FALSE
	);
	ALTER TABLE docwin.e_socios_inter_comer_tb
	  OWNER TO docwin_owner;
	GRANT ALL ON TABLE docwin.e_socios_inter_comer_tb TO docwin_owner;
	GRANT ALL ON TABLE docwin.e_socios_inter_comer_tb TO supervisores;
	GRANT ALL ON TABLE docwin.e_socios_inter_comer_tb TO escreventes;

	IF NOT EXISTS(SELECT column_name FROM information_schema.columns WHERE table_schema='docwin' AND table_name='e_prin_tb' AND column_name='pjh_id') 
	THEN
		ALTER TABLE docwin.e_prin_tb ADD COLUMN pjh_id bigint;
		COMMENT ON COLUMN docwin.e_prin_tb.pjh_id IS 'ID historioco pj - interdicao comercial';
	END IF;
	
	IF NOT EXISTS (SELECT * FROM docwin.aux_func_tb WHERE fu_cod = 632 and fu_mod = 'E')
    THEN
		INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) VALUES (632, 'E', 'Qualifica��o da pessoa jur�dica interditada comercialmente', 'Fun��o especial. Qualifica��o da pessoa jur�dica interditada comercialmente.', 4, 'F', NULL, NULL, NULL, NULL);
		INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) VALUES (633, 'E', 'Qualifica��o dos s�cios da empresa interditada comercialmente', 'Fun��o especial. Qualifica��o dos s�cios da empresa interditada comercialmente.', 4, 'F', NULL, NULL, NULL, NULL);
	END IF;
	
	IF NOT EXISTS (SELECT * FROM docwin.aux_func_tb WHERE fu_cod = 415 and fu_mod = 'E')
    THEN
		INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) VALUES (415, 'E', 'N�mero da(s) p�gina(s) que foi publicada no di�rio oficial a interdi��o comercial.', 'Campo do bando de dados. N�mero da(s) p�gina(s) que foi publicada no di�rio oficial a interdi��o comercial.', 0, 'T', NULL, NULL, NULL, NULL);
	END IF;	
	
	IF EXISTS (SELECT * FROM docwin.aux_func_tb WHERE fu_cod = 424 and fu_mod = 'E')
    THEN
		UPDATE docwin.aux_func_tb SET fu_dsc='Campo do banco de dados. Vara em que foi proferida a senten�a.' WHERE fu_cod=424 AND fu_mod='E';
	END IF;
	
	IF EXISTS (SELECT * FROM docwin.aux_func_tb WHERE fu_cod = 301 and fu_mod = 'E')
    THEN
		UPDATE docwin.aux_func_tb SET fu_tit='Interdi��o comercial: Nome do administrador | Demais atos: Nome do tutor ou curador' WHERE fu_cod=301 AND fu_mod='E';
	END IF;
	
	IF EXISTS (SELECT * FROM docwin.aux_func_tb WHERE fu_cod = 423 and fu_mod = 'E')
    THEN
		UPDATE docwin.aux_func_tb SET fu_tit='Interdi��o comercial: Data dos feitos | Demais atos: Data de expedi��o do mandado judicial' WHERE fu_cod=423 AND fu_mod='E';
	END IF;
	
	IF EXISTS (SELECT * FROM docwin.aux_func_tb WHERE fu_cod = 442 and fu_mod = 'E')
    THEN
		UPDATE docwin.aux_func_tb SET fu_tit='Interdi��o comercial: Nome do Juiz/Desembargador | Demais atos: Juiz que prolatou a senten�a ou nome do tradutor da certid�o' WHERE fu_cod=442 AND fu_mod='E';
	END IF;
	
	IF EXISTS (SELECT * FROM docwin.aux_func_tb WHERE fu_cod = 447 and fu_mod = 'E')
    THEN
		UPDATE docwin.aux_func_tb SET fu_tit='Interdi��o comercial: Nro. processo administrativo | Demais atos: Lv, fls, n� do registro da tradu��o da certid�o no RTD' WHERE fu_cod=447 AND fu_mod='E';
	END IF;
	
	IF EXISTS (SELECT * FROM docwin.aux_func_tb WHERE fu_cod = 445 and fu_mod = 'E')
    THEN
		UPDATE docwin.aux_func_tb SET fu_tit='Interdi��o comercial: Data de publica��o no di�rio oficial | Demais atos: Data do registro no RTD da tradu��o da certid�o estrangeira' WHERE fu_cod=445 AND fu_mod='E';
	END IF;
	
	IF EXISTS (SELECT * FROM docwin.aux_func_tb WHERE fu_cod = 443 and fu_mod = 'E')
    THEN
		UPDATE docwin.aux_func_tb SET fu_tit='Interdi��o comercial: Nome do liquidante judical | Demais atos: Local da tradu��o (cidade/UF) onde atua o tradutor' WHERE fu_cod=443 AND fu_mod='E';
	END IF;
	
	IF EXISTS (SELECT * FROM docwin.aux_func_tb WHERE fu_cod = 441 and fu_mod = 'E')
    THEN
		UPDATE docwin.aux_func_tb SET fu_tit='Interdi��o comercial: Matr�cula do liquidante | Demais atos: Idioma da qual a certid�o original foi traduzida' WHERE fu_cod=441 AND fu_mod='E';
	END IF;
	
	IF EXISTS (SELECT * FROM docwin.aux_func_tb WHERE fu_cod = 444 and fu_mod = 'E')
    THEN
		UPDATE docwin.aux_func_tb SET fu_tit='Interdi��o comercial: Data de nomea��o do liquidante | Demais atos: Data da tradu��o da certid�o do exterior a ser trasladada' WHERE fu_cod=444 AND fu_mod='E';
	END IF;
	
	IF EXISTS (SELECT * FROM docwin.aux_func_tb WHERE fu_cod = 636 and fu_mod = 'P')
    THEN
		UPDATE docwin.aux_func_tb SET fu_tit='Assinantes do ato para certid�o/traslado' WHERE fu_cod=636 AND fu_mod='P';
	END IF;
	IF EXISTS (SELECT * FROM docwin.aux_func_tb WHERE fu_cod = 634 and fu_mod = 'P')
    THEN
		UPDATE docwin.aux_func_tb SET fu_tit='Informa��o do livro e folhas',fu_lnk=4 WHERE fu_cod=634 AND fu_mod='P';
	END IF;
		
	IF NOT EXISTS(SELECT column_name FROM information_schema.columns WHERE table_schema='docwin' AND table_name='p_atos_tb' AND column_name='at_textopoder') 
	THEN
		ALTER TABLE docwin.p_atos_tb
			ADD COLUMN at_textopoder text;
	END IF;		
	
	IF NOT EXISTS (SELECT * FROM docwin.aux_func_tb WHERE fu_cod = 641 and fu_mod = 'P')
    THEN
		INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) VALUES (641, 'P', 'Poderes do substabelecimento', 'Fun��o especial. Retorna o texto com o(s) podere(s) do substabelecimento.', 4, 'F', NULL, NULL, NULL, NULL);
	END IF;
	
	CREATE INDEX IF NOT EXISTS idx_aux_help_tb
   ON docwin.aux_help_tb USING btree (hlp_codigo ASC NULLS LAST);
	
	
END;
$$ LANGUAGE plpgsql VOLATILE;
GRANT EXECUTE ON FUNCTION docwin.release_0_8() TO escreventes;
GRANT EXECUTE ON FUNCTION docwin.release_0_8() TO supervisores;
SELECT docwin.release_0_8();
DROP FUNCTION IF EXISTS docwin.release_0_8();



--Script Pedro

CREATE OR REPLACE FUNCTION docwin.criarPermissoes() RETURNS void as
$$
BEGIN
 

UPDATE docwin.aux_tfun_tb SET  tf_sub = 420 WHERE tf_id = 432;
UPDATE docwin.aux_tfun_tb SET  tf_sub  = 420 WHERE tf_id = 431;


    IF NOT EXISTS (SELECT * FROM docwin.aux_tfun_tb WHERE tf_id = 428)
	THEN
		INSERT INTO docwin.aux_tfun_tb(tf_id, tf_prog, tf_nomfun, tf_sub, tf_perm)
		VALUES (428, 'U_RE_CNFC', 'Relat�rio de Confer�ncia de Caixa', 420, '');
	END IF;
	
	

	IF NOT EXISTS (SELECT * FROM docwin.aux_tfun_tb WHERE tf_id = 428)
	THEN
		INSERT INTO docwin.aux_tfun_tb(tf_id, tf_prog, tf_nomfun, tf_sub, tf_perm)
		VALUES (428, 'U_RE_CNFC', 'Relat�rio de Confer�ncia de Caixa', 420, '');
	END IF;
	
		IF NOT EXISTS (SELECT * FROM docwin.aux_tfun_tb WHERE tf_id = 429)
	THEN
		INSERT INTO docwin.aux_tfun_tb(tf_id, tf_prog, tf_nomfun, tf_sub, tf_perm)
		VALUES (429, 'U_RE_CFCT', 'Relat�rio de Confer�ncia de Caixa (Em Tela)', 420, '');
	END IF;
	
			IF NOT EXISTS (SELECT * FROM docwin.aux_tfun_tb WHERE tf_id = 438)
	THEN
		INSERT INTO docwin.aux_tfun_tb(tf_id, tf_prog, tf_nomfun, tf_sub, tf_perm)
		VALUES (438, 'U_RE_ATOG', 'Relat�rio de Atos Praticados (Guia)', 420, '');
	END IF;
	
	
	IF NOT EXISTS (SELECT * FROM docwin.aux_tfun_tb WHERE tf_id = 439)
	THEN
		INSERT INTO docwin.aux_tfun_tb(tf_id, tf_prog, tf_nomfun, tf_sub, tf_perm)
		VALUES (439, 'U_RE_ATOP', 'Relat�rio de Atos Praticados (Portal)', 420, '');
	END IF;
	

	
 
END;
$$ LANGUAGE plpgsql VOLATILE;
GRANT EXECUTE ON FUNCTION docwin.criarPermissoes() TO escreventes;
GRANT EXECUTE ON FUNCTION docwin.criarPermissoes() TO supervisores;
SELECT docwin.criarPermissoes();
DROP FUNCTION IF EXISTS docwin.criarPermissoes();


CREATE OR REPLACE FUNCTION docwin.colunas() RETURNS void as
$$
BEGIN


	IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
                   WHERE table_schema='docwin' AND table_name='u_emolumento_tb' AND column_name='acumula_qtd_livro_caixa' )
    THEN
		ALTER TABLE docwin.u_emolumento_tb ADD COLUMN acumula_qtd_livro_caixa boolean;
    END IF;
	
	
	IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
                   WHERE table_schema='docwin' AND table_name='u_emolumento_tb' AND column_name='acumula_qtd_livro_diario_aux' )
    THEN
		ALTER TABLE docwin.u_emolumento_tb ADD COLUMN acumula_qtd_livro_diario_aux boolean;
    END IF;
	
	
	IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
                   WHERE table_schema='docwin' AND table_name='u_emolumento_tb' AND column_name='acumula_qtd_ordens_servicos' )
    THEN
		ALTER TABLE docwin.u_emolumento_tb ADD COLUMN acumula_qtd_ordens_servicos boolean;
    END IF;
		
	
    IF EXISTS (SELECT column_name FROM information_schema.columns 
                   WHERE table_schema='docwin' AND table_name='u_emolumento_tb' AND column_name='acumula_qtd' )
    THEN
	    --Seta o valor que est� na coluna acumula_qtd para as novas colunas, depois exclui
	    UPDATE docwin.u_emolumento_tb SET acumula_qtd_livro_caixa = acumula_qtd, acumula_qtd_livro_diario_aux = acumula_qtd, acumula_qtd_ordens_servicos = acumula_qtd;		
		ALTER TABLE docwin.u_emolumento_tb DROP COLUMN acumula_qtd;
    END IF;
	

 
END;
$$ LANGUAGE plpgsql VOLATILE;
GRANT EXECUTE ON FUNCTION docwin.colunas() TO escreventes;
GRANT EXECUTE ON FUNCTION docwin.colunas() TO supervisores;
SELECT docwin.colunas();
DROP FUNCTION IF EXISTS docwin.colunas();


--0.9


SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox1.cmbTipoAto','ato','ato');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox1.cmbTipoAto','

   Ato que esta sendo lavrado:
 
   <b>Procura��o</b>,
   <b>Substabelecimento</b>,
   <b>Ren�ncia</b>,
   <b>Revoga��o</b>.
   ','Ato');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox1.cmbSubstabelecimento','

   Neste campo � informado se poder� 
   ou  n�o ser realizado o substabe-
   lecimento.','Substabelecimento');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.pnlReservaPoderes.cmbReservaPoderes','

   Define-se se haver� reserva de 
   poderes no substabelecimento.','Reserva de poderes');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox1.cmbValidade','

    Define-se  a forma de validade
    do ato que est� sendo lavrado.','Validade');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.pnlDataFinal.txtDataFinal','

   Define-se a data de validade do
   ato que est� sendo lavrado.','Validade');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.pnlAnoMesDias.txtAno','


   Define-se a validade do ato lavrado
   em <b>anos</b>.','Valdiade em anos');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.pnlAnoMesDias.txtM�s','

   Define-se a validade do ato lavrado
   em <b>meses</b>.','Validade em meses');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.pnlAnoMesDias.txtDias','

   Define-se a validade do ato lavrado
   em <b>dias</b>.','Validade em dias');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox1.cmbEmDilig�ncia','

   Define-se a lavratura foi realizada
   em dilig�ncia.

<h>
 
   <b>OBS</b>: Ao informar que <b>SIM</b>, ser� ha-
   bilitado um campo para informar o 
   local da dilig�ncia.
  ','Lavratura em dilig�ncia?');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.pnlLocalDiligencia.txtLocalDiligencia','

   Define-se o local da lavratura do
   ato em dilig�ncia.

<h>

   <b>OBS</b>.: Ao  informar  o CEP do local
   no in�cio do campo o sistema auto-
   maticamente  buscar� o logradouro,
   deixando  o  cursor  na posi��o do
   n�mero a ser preenchido.','Local da dilig�ncia');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.grpDadosAto.cmbLocalLavraturaAtoOriginal','

    Serventia onde foi lavrado o ato
    original.','Serventia');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.grpDadosAto.txtLivroNomeAtoOriginal','


   Nome do livro (caso exista) em que
   foi lavrado o ato original.

   Ex.: para livro <b>P</b>, 
		informar apenas <b>P</b>.','Nome do livro');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.grpDadosAto.txtLivroComplementoAtoOriginal','
  Identifica��o complementar do livro. 
    
  Ex.: para livro n� 100<b>F</b>,
		 informar apenas <b>F</b>.','Complemento do livro');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.grpDadosAto.txtLivroNumeroAtoOriginal','

    N�mero do livro em que foi lavrado
    o ato original.','N�mero do livro');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.grpDadosAto.txtPaginaInicialAtoOriginal','

   P�gina do livro onde foi lavrado o
   ato original.','P�gina inicial do livro');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.grpDadosAto.txtPaginaFinalAtoOriginal','

   P�gina do livro onde foi lavrado o
   ato original.','P�gina final do livro');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.grpDadosAto.txtFolhaComplementoAtoOriginal','
  Identifica��o complementar da folha 

  Ex.: para folha n� 123<b>G</b>,
		informar apenas <b>G</b>.','Complemento da p�gina');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.grpDadosAto.txtDataLavraturaAtoOriginal','

   Data da lavratura do ato original.','Data da lavratura');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.grpDadosAto.cmbPermitiaSubstabelecimentoAtoOriginal','
  
   Define-se se no ato original �
   permitido substabelecimento.','Substabelecimento');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.grpDadosAto.cmbPermitiaRevogacaoAtoOriginal','
   Neste campo � informado se no ato
   original � permitido a revoga��o.
','Revoga��o');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.pnlLocal.txtLocalLavraturaAtoOriginal','

  Nome da serventia em que foi lavrado
  o ato original.	','Nome da serventia');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.pnlLavrou.txtNomeLavrouAtoOriginal','

   Nome do respons�vel pela lavratura
   do ato original.','Nome ');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.pnlArquivo.txtArquivoPastaAtoOriginal','

   Pasta em que se foi realizada os
   arquivamentos   no(a)  serventia
   de lavratura do ato original.','Pasta ');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.pnlArquivo.txtArquivoNumeroAtoOriginal','


   N� da pasta em que se foi realizado 
   os arquivamentos   no(a)  serventia
   de lavratura do ato original.','N� da pasta');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.pnlArquivo.txtArquivoPastaAtoOriginal','

   Pasta em que se foi realizado os
   arquivamentos   no(a)  serventia
   de lavratura do ato original.','Pasta ');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox7.txtCep','


   CEP do logradouro da serventia
   de lavratura do ato original.','CEP');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox7.txtEndereco','


   Logradouro da serventia de lavratura 
   do ato original.','Logradouro');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox7.txtNumero','

   N�mero do logradouro da serventia
   de lavratura do ato original.','N�mero');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox7.txtBairro','

   Bairro do logradouro da serventia
   de lavratura do ato original.','Bairro');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox7.txtCidade','

   Cidade  da serventia de lavratura 
   do ato original.','Cidade');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox7.txtBairro','

   Bairro da serventia de lavratura 
   do ato original.','Bairro');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox7.txtComplemento','

   Complemento do logradouro da serventia
   de lavratura do ato original.','Complemento');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox7.txtPais','

   Pa�s da serventia de lavratura 
   do ato original.','Pa�s');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.pnlLocal.txtLocalLavraturaAtoOriginal','

  Nome do local em que foi lavrado
  o ato original.	


','Nome da serventia/Unidade consular');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox12.cmbTipoLivro','

   Selecione o livro em que est� sendo
   lavrado o ato.

 <h>

   <b>OBS</b>.: A configura��o do livro pode
   ser alterada no menu:

   Procura��es > 
	Configura��es >
		Numera��o Autom�tica','Livro');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox12.txtLivroNome','


   Nome do livro (caso exista) em que
   est� ser� lavrado.

   Ex.: para livro <b>P</b>, 
		informar apenas <b>P</b>.','Livro');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox12.txtLivroComplemento','
  Identifica��o complementar do livro. 
    
  Ex.: para livro n� 100<b>F</b>,
		 informar apenas <b>F</b>.','Complemento do livro');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox12.txtLivroNumero','

   N�mero do livro em que ser� lavrado.','N�mero do livro');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox12.txtPaginaNumero','

   P�gina do livro onde ser� lavrado.','P�gina inicial');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox12.txtPaginaNumeroFinal','
  

   P�gina do livro onde ser� lavrado.','P�gina final');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox12.txtPaginaComplemento','
  Identifica��o complementar da folha 

  Ex.: para folha n� 123<b>G</b>,
		informar apenas <b>G</b>.','Complemento da p�gina');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox12.txtDataAto','


   Data de lavratura do ato.','Data de lavratura');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmProcuracoes.groupBox12.cmbStatus','
		
   Status do ato lavrado.','Status do ato');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmAssentamentoTexto.panel1.txtNomeServentia','

  Nome  da  serventia onde foi lavrado
  o ato que deu origem a esta anota��o','Nome da serventia');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmAssentamentoTexto.panel1.txtLivro','

  N�mero  do  livro  onde  foi lavrado
  o ato que deu origem a esta anota��o','N�mero do livro');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmAssentamentoTexto.panel1.txtFolhas','


   N�mero  da  folha onde  foi lavrado
  o ato que deu origem a esta anota��o','Folha');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmAssentamentoTexto.panel1.txtDataAto','

   Data de lavratura do ato que deu 
   origem a esta anota��o.','Data de lavratura');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmAssentamentoTexto.panel1.txtPasta','

   Pasta  em  que  foi arquivado na 
   serventia  em  que foi lavrado o
   ato que deu origem a esta anota-
   ��o.','Pasta');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmAssentamentoTexto.panel1.txtArquivo','	

 
   Arquivo em que  foi arquivado na 
   serventia  em  que foi lavrado o
   ato que deu origem a esta anota-
   ��o.','Arquivo');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmAssentamentoTexto.panel1.cmbReservaPoderes','

  Informar neste campo se h� reserva de
  poderes  no ato que deu origem a esta
  anota��o.','Com reserva de poderes?');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmAssentamentoTexto.panel1.cmbAssinantes','

   Assinante desta anota��o.','Assinante');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmPoderes.groupBox2.txtCodigo','

   C�digo para facilitar identifica��o
   no momento da inclus�o no ato.','C�digo do poder');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmPoderes.groupBox2.cmbAtos','

  Qual ato poder� utilizar este poder.','Atos');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmPoderes.groupBox2.txtTitulo','

   T�tulo deste poder. Ser� exibido 
   na  lista  de sele��o na tela de
   inclus�o no ato.
','T�tulo');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmPoderes.groupBox2.cmbTipo','

  Utilizado para organizar e facilitar
  as  buscas  pelo poder no momento de
  incluir no ato.','Tipo');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmPoderes.groupBox3.txtDescricao','

  Orienta��es para a utiliza��o deste
  poder.','Orienta��es');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmPoderes.grdDescricaoPoder.ttcMinuta','

  Texto com a minuta do poder.

<h>

  <b>OBS.</b>: No rodape desta tela � exibido
  os  atalhos para inclus�o de fun��es
  e campos vari�vies.','Minuta do poder');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmCamposVariaveis.groupBox3.txtTitulo','

  Esta informa��o vir� a frente do
  campo para preenchimento.','Campo');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmCamposVariaveis.groupBox3.txtDescricao','

  Descri��o do campo vari�vel.','Descri��o');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmCamposVariaveis.panelCampoTexto.txtMask','

  Neste campo voc� define a m�scara de 
  formata��o para o campo.

  Pode-se utilizar:

  ','M�scara de formata��o');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmCamposVariaveis.panelCampoTexto.txtMask','

  Neste campo voc� define a m�scara de 
  formata��o para o campo.

  Pode-se utilizar:

  <b>0 ou 9</b> para d�gitos num�ricos.
  <b>L ou ?</b> para d�gitos letras.
  <b>A ou a</b> para d�gitos alfanum�ricos.
       <b>></b> para converter d�gitos para
	 mai�sculo.
       <b><</b> para converter d�gitos para
         min�sculo.

  <b>Exemplos de mascaras:</b>

  Placa de ve�culo: 	>LLL-9999
  Data:			99/99/9999
  Hora:			99:99
  CPF 			999\.999\.999-99

  <b>OBS.</b>: Quando se utilizar ponto (.)  na
  m�scara  deve-se  colocar   antes  uma  
  barra (\) como no exemplo do CPF. Isto
  se faz necess�rio pois dependendo das 
  configura��es do sistema operacional, 
  quando   n�o  utiliza-se  a  barra, � 
  trocado o ponto (.) por v�rgula (,).

  ','M�scara de formata��o');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.P.frmTipoPoder.grdJustificativa.txtDocumento','

   Descri��o do tipo de poder.','Descri��o');
SELECT docwin.inserealterahelp('P','T','PT600C','
 Indica se a data por extenso ter� o 
 primeiro caractere mai�sculo ou n�o.

 S - Retornar� a data come�ando com letra
     mai�scula.

 N - Retornar� a data come�ando com letra
     min�scula.','Inicia em mai�sculo');
SELECT docwin.inserealterahelp('P','T','PT600B2',' 
 Indique aqui quantos dias a mais ou a
 menos se refere a data cujo extenso voc�
 deseja que apare�a em seu documento.

 Voc� j� selecionou uma data. Se deseja
 exatamente o extenso da data que for
 digitada no campo selecionado, ent�o
 simplesmente deixe ZERADO este campo.
 
 Caso queira um extenso de uma data pos-
 terior ou inferior a que est� digitada
 no campo que voc� selecionou, ent�o
 digite quantos dias a mais ou a menos
 NESTE CAMPO. Se a data � posterior (+)
 ou inferior (-) voc� definiu no campo
 anterior, digitando os sinais de subtra-
 ��o ou adi��o.','Adicional');
SELECT docwin.inserealterahelp('P','T','PT600B',' Este argumento indica se voc� quer o
 extenso de uma data posterior ou ante-
 rior � indicada.

 Isso � particularmente �til quando voc�
 deseja introduzir em seu documento o
 extenso de uma data que n�o � digitada,
 mas que tem rela��o direta com outra,
 tipo... 10 dias antes ou 30 dias ap�s !

 Nos casos acima, respectivamente, voc�
 digitaria o sinal de subtra��o (ou
 h�fen "-") e o sinal de adi��o ("+")
 NESTE CAMPO e no campo seguinte 10 e
 30.','Modificador');
SELECT docwin.inserealterahelp('P','T','PT600A','
 Voc� possui 8 tipos de extenso de datas.
 Para  facilitar a compreens�o das  dife-
 ren�as de  cada  tipo,  vamos  tomar  um
 exemplo e  ver  qual o retorno da fun��o
 conforme cada tipo:

      Data exemplo: 03/05/1992

 Tipo  Extenso
 ----  ----------------------------------

   1   terceiro dia do m�s de maio de mil
       novecentos e noventa e dois

   2   tr�s de maio de mil novecentos e
       noventa e dois

   3   3 de maio de 1992

   4   ao terceiro (3) dia do m�s de maio
       (5) do ano de mil novecentos e
       noventa e dois (1992)

   5   Ao terceiro (3) dia do m�s de maio
       (5) do ano de mil novecentos e
       noventa e dois (1992)

   6   19920503

   7   ao terceiro (3) dia de maio de
       mil novecentos e noventa e dois
       (1992)
  
   8   Ao terceiro (3) dia de maio de
       mil novecentos e noventa e dois
       (1992)

   9   tr�s (03) de maio de 1992
   
   10  apenas o dia, para as novas
       certid�es
	   
   11  apenas o m�s, para as novas
       certid�es
	   
   12  apenas o ano, para as novas
       certid�es	
	   
 Obs.: com rela��o aos tipos de extenso
       4, 5, 7 e 8 ressaltamos o seguin-
       te:

       a) a diferen�a entre um tipo e
          outro, como pode-se observar
          no exemplo, � apenas a primei-
          ra letra, que para o tipo 4 e
          7 � min�scula e para o tipo 5
          e 8 � mai�scula (ao/aos ou
          Ao/Aos)

       b) caso o dia da data seja supe-
          rior a 3, troca-se o extenso
          do dia da forma ordinal para a
          forma cardinal. Veja o exemplo
          a seguir.
 
          Data exemplo: 05/05/1992
          Resultado...
 
          Tipo 4:

          "aos cinco (5) dias do m�s de
           maio (5) do ano de mil
           novecentos e noventa e dois
           (1992)"
 
          Tipo 5:
 
          "aos cinco (5) de maio de mil
           novecentos e noventa e dois
           (1992)"
','Tipo');

-- Function: docwin.log_p_ato_tb()

-- DROP FUNCTION docwin.log_p_ato_tb();

CREATE OR REPLACE FUNCTION docwin.log_p_ato_tb()
  RETURNS trigger AS
$BODY$ 
 DECLARE
     ri RECORD;
     campo_novo TEXT;
     campo_antigo text;
 BEGIN

  RAISE NOTICE 'Excluindo registro da tabela: %', quote_ident(TG_relname);

  if (quote_ident(TG_relname) = 'p_participantes_tb' or quote_ident(TG_relname) = 'p_participantes_sefaz_tb') then
 	if ( TG_OP = 'INSERT') then	
 		insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 
 				   (new.at_key   ,'Participante inserido'      ,quote_ident(TG_relname), ''            ,(SELECT CASE  WHEN new.pa_tipo = 'F' THEN 
 								(SELECT 'CPF n� ' || lpad(ph_cpf::text, 11,'0') FROM docwin.pessoa_fisica_historico_tb WHERE new.pa_id = ph_id) ELSE 
 								(SELECT 'CNPJ n� ' || lpad(pjh_cnpj::text,15,'0') FROM docwin.pessoa_juridica_historico_tb WHERE new.pa_id = pjh_id) END)      ,now()            ,user);
 	else 
 		if ( TG_OP = 'DELETE') then
 			insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 
 				 (old.at_key    ,'Participante excluído'      	,quote_ident(TG_relname), (SELECT CASE  WHEN old.pa_tipo = 'F' THEN 
 								(SELECT 'CPF n� ' || lpad(ph_cpf::text, 11,'0') FROM docwin.pessoa_fisica_historico_tb WHERE old.pa_id = ph_id) ELSE 
 								(SELECT 'CNPJ n� ' || lpad(pjh_cnpj::text,15,'0') FROM docwin.pessoa_juridica_historico_tb WHERE old.pa_id = pjh_id) END)  ,''		,now()        		,user);
 		end if;	
 	end if;
 
     FOR ri IN
         SELECT  column_name
         FROM information_schema.columns
         WHERE
             table_schema = quote_ident(TG_TABLE_SCHEMA)
         AND table_name = quote_ident(TG_TABLE_NAME)
         ORDER BY ordinal_position
     LOOP
 	if ( TG_OP = 'UPDATE') then		
 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_antigo using old;
 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_novo using NEW;
 		if campo_novo <> campo_antigo then
 			insert into docwin.p_log_modificacoes_tb (id      , campo_modificado, tabela                , valor_anterior  , valor_posterior, data_modificacao, usuario) values 
 				        (old.at_key  ,ri.column_name || ' do participante ' ||  (SELECT CASE  WHEN old.pa_tipo = 'F' THEN 
 								(SELECT 'CPF n� ' || lpad(ph_cpf::text, 11,'0') FROM docwin.pessoa_fisica_historico_tb WHERE old.pa_id = ph_id) ELSE 
 								(SELECT 'CNPJ n� ' || lpad(pjh_cnpj::text,15,'0') FROM docwin.pessoa_juridica_historico_tb WHERE old.pa_id = pjh_id) END)   || ' do ato ' || (SELECT 'Livro ' || at_livronome::text || '-' || (CASE WHEN at_livronumero < 0 THEN '*' ELSE at_livronumero::text END) 
 			|| ', Pag. ini. '  || (CASE WHEN at_folhanumero < 0 THEN '*' ELSE at_folhanumero::text END) 
 			|| ' e Pag. final. '  || (CASE WHEN at_folhanumerofinal < 0 THEN '*' ELSE at_folhanumerofinal::text END)
 				FROM docwin.p_atos_tb WHERE at_key=old.at_key)   ,quote_ident(TG_relname), campo_antigo    ,campo_novo      ,now()      ,user);
                 end if;
         end if;       
     END LOOP;
     RETURN NEW;
 
 elseif (quote_ident(TG_relname) = 'p_participantes_representantes_tb') then
 	if ( TG_OP = 'INSERT') then	
 		insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 
 				   (new.at_key   ,'Representante inserido'      ,quote_ident(TG_relname), ''            ,((SELECT CASE  WHEN new.re_tipo = 'F' THEN 
 								(SELECT 'Representante ' || ph_nome FROM docwin.pessoa_fisica_historico_tb WHERE new.re_id = ph_id) ELSE 
 								(SELECT 'Representante ' || pjh_razao FROM docwin.pessoa_juridica_historico_tb WHERE new.re_id = pjh_id) END) || ' do participante ' || (SELECT CASE  WHEN pa_tipo = 'F' THEN 
 								(SELECT 'CPF n� ' || lpad(ph_cpf::text, 11,'0') FROM docwin.pessoa_fisica_historico_tb WHERE new.pa_id = ph_id) ELSE 
 								(SELECT 'CNPJ n� ' || lpad(pjh_cnpj::text,15,'0') FROM docwin.pessoa_juridica_historico_tb WHERE new.pa_id = pjh_id) END 
 								 FROM docwin.p_participantes_tb WHERE p_participantes_tb.at_key = new.at_key AND p_participantes_tb.pa_id = new.pa_id))      ,now()            ,user);
 	else 
 		if ( TG_OP = 'DELETE') then
 			insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 
 				 (old.at_key    ,'Representante excluído'      	,quote_ident(TG_relname), ((SELECT CASE  WHEN old.re_tipo = 'F' THEN 
 								(SELECT 'Representante ' || ph_nome FROM docwin.pessoa_fisica_historico_tb WHERE old.re_id = ph_id) ELSE 
 								(SELECT 'Representante ' || pjh_razao FROM docwin.pessoa_juridica_historico_tb WHERE old.re_id = pjh_id) END) || ' do participante ' || (SELECT CASE  WHEN pa_tipo = 'F' THEN 
 								(SELECT 'CPF n� ' || lpad(ph_cpf::text, 11,'0') FROM docwin.pessoa_fisica_historico_tb WHERE old.pa_id = ph_id) ELSE 
 								(SELECT 'CNPJ n� ' || lpad(pjh_cnpj::text,15,'0') FROM docwin.pessoa_juridica_historico_tb WHERE old.pa_id = pjh_id) END 
 								 FROM docwin.p_participantes_tb WHERE p_participantes_tb.at_key = old.at_key AND p_participantes_tb.pa_id = old.pa_id))  ,''		,now()        		,user);
 		end if;	
 	end if;
 elseif (quote_ident(TG_relname) = 'p_participantes_rogo_tb') then
 	if ( TG_OP = 'INSERT') then	
 		insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 
 				   (new.at_key   ,'Rogo inserido'      ,quote_ident(TG_relname), ''            ,((SELECT 'Rogo ' || ph_nome FROM docwin.pessoa_fisica_historico_tb WHERE new.pf_id = ph_id)
 								|| ' do participante ' || (SELECT CASE  WHEN pa_tipo = 'F' THEN 
 								(SELECT 'CPF n� ' || lpad(ph_cpf::text, 11,'0') FROM docwin.pessoa_fisica_historico_tb WHERE new.pa_id = ph_id) ELSE 
 								(SELECT 'CNPJ n� ' || lpad(pjh_cnpj::text,15,'0') FROM docwin.pessoa_juridica_historico_tb WHERE new.pa_id = pjh_id) END 
 								 FROM docwin.p_participantes_tb WHERE p_participantes_tb.at_key = new.at_key AND p_participantes_tb.pa_id = new.pa_id))      ,now()            ,user);
 	else 
 		if ( TG_OP = 'DELETE') then
 			insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 
 				 (old.at_key    ,'Rogo excluido'      	,quote_ident(TG_relname), ((SELECT 'Rogo ' || ph_nome FROM docwin.pessoa_fisica_historico_tb WHERE old.pf_id = ph_id)  
 								|| ' do participante ' || (SELECT CASE  WHEN pa_tipo = 'F' THEN 
 								(SELECT 'CPF n� ' || lpad(ph_cpf::text, 11,'0') FROM docwin.pessoa_fisica_historico_tb WHERE old.pa_id = ph_id) ELSE 
 								(SELECT 'CNPJ n� ' || lpad(pjh_cnpj::text,15,'0') FROM docwin.pessoa_juridica_historico_tb WHERE old.pa_id = pjh_id) END 
 								 FROM docwin.p_participantes_tb WHERE p_participantes_tb.at_key = old.at_key AND p_participantes_tb.pa_id = old.pa_id))  ,''		,now()        		,user);
 		end if;	
 	end if;
 elseif (quote_ident(TG_relname) = 'p_participantes_testestemunhas_tb') then
 	if ( TG_OP = 'INSERT') then	
 		insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 
 				   (new.at_key   ,'Testemunha inserida'      ,quote_ident(TG_relname), ''            ,((SELECT 'Testemunha ' || ph_nome FROM docwin.pessoa_fisica_historico_tb WHERE new.pf_key = ph_id)
 								|| ' do participante ' || (SELECT CASE  WHEN pa_tipo = 'F' THEN 
 								(SELECT 'CPF n� ' || lpad(ph_cpf::text, 11,'0') FROM docwin.pessoa_fisica_historico_tb WHERE new.pa_id = ph_id) ELSE 
 								(SELECT 'CNPJ n� ' || lpad(pjh_cnpj::text,15,'0') FROM docwin.pessoa_juridica_historico_tb WHERE new.pa_id = pjh_id) END 
 								 FROM docwin.p_participantes_tb WHERE p_participantes_tb.at_key = new.at_key AND p_participantes_tb.pa_id = new.pa_id))      ,now()            ,user);
 	else 
 		if ( TG_OP = 'DELETE') then
 			insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 
 				 (old.at_key    ,'Testemunha excluida'      	,quote_ident(TG_relname), ((SELECT 'Testemunha ' || ph_nome FROM docwin.pessoa_fisica_historico_tb WHERE old.pf_key = ph_id)  
 								|| ' do participante ' || (SELECT CASE  WHEN pa_tipo = 'F' THEN 
 								(SELECT 'CPF n� ' || lpad(ph_cpf::text, 11,'0') FROM docwin.pessoa_fisica_historico_tb WHERE old.pa_id = ph_id) ELSE 
 								(SELECT 'CNPJ n� ' || lpad(pjh_cnpj::text,15,'0') FROM docwin.pessoa_juridica_historico_tb WHERE old.pa_id = pjh_id) END 
 								 FROM docwin.p_participantes_tb WHERE p_participantes_tb.at_key = old.at_key AND p_participantes_tb.pa_id = old.pa_id))  ,''		,now()        		,user);
 		end if;	
 	end if;
 elseif (quote_ident(TG_relname) = 'p_atos_poderes_tb' or quote_ident(TG_relname) = 'p_atos_poderes_campos_variaveis_tb') then
 	if ( TG_OP = 'INSERT') then	
 		insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 
 				   (new.at_key   ,'Poder inserido'      ,quote_ident(TG_relname), ''            ,(SELECT 'Poder ' || po_titulo FROM docwin.p_poderes_tb WHERE new.po_key = po_key)
 								      ,now()            ,user);
 	else 
 		if ( TG_OP = 'DELETE') then
 			insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 
 				 (old.at_key    ,'Poder excluido'      	,quote_ident(TG_relname), (SELECT 'Poder ' || po_titulo FROM docwin.p_poderes_tb WHERE old.po_key = po_key)  
 								  ,''		,now()        		,user);
 		end if;	
 	end if;
 
     FOR ri IN
         SELECT  column_name
         FROM information_schema.columns
         WHERE
             table_schema = quote_ident(TG_TABLE_SCHEMA)
         AND table_name = quote_ident(TG_TABLE_NAME)
         ORDER BY ordinal_position
     LOOP
 	if ( TG_OP = 'UPDATE') then		
 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_antigo using old;
 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_novo using NEW;
 		if campo_novo <> campo_antigo then
 			insert into docwin.p_log_modificacoes_tb (id      , campo_modificado, tabela                , valor_anterior  , valor_posterior, data_modificacao, usuario) values 
 				        (old.at_key  ,ri.column_name || ' ' || (SELECT ' do poder ' || po_titulo FROM docwin.p_poderes_tb WHERE old.po_key = po_key)   || ' do ato ' || (SELECT 'Livro ' || p_atos_tb.at_livronome::text || '-' || (CASE WHEN p_atos_tb.at_livronumero < 0 THEN '*' ELSE at_livronumero::text END) 
 			|| ', Pag. ini. '  || (CASE WHEN at_folhanumero < 0 THEN '*' ELSE at_folhanumero::text END) 
 			|| ' e Pag. final. '  || (CASE WHEN at_folhanumerofinal < 0 THEN '*' ELSE at_folhanumerofinal::text END)
 				FROM docwin.p_atos_tb WHERE at_key=old.at_key)   ,quote_ident(TG_relname), campo_antigo    ,campo_novo      ,now()      ,user);
                 end if;
         end if;       
     END LOOP;
     RETURN NEW;
 
 elseif (quote_ident(TG_relname) = 'p_testetmunhas_ato') then
 	if ( TG_OP = 'INSERT') then	
 		insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 
 				   (new.at_key   ,'Testemunha do ato inserida'      ,quote_ident(TG_relname), ''            ,(SELECT 'Testemunha ' || ph_nome FROM docwin.pessoa_fisica_historico_tb WHERE new.pf_id = ph_id)      ,now()            ,user);
 	else 
 		if ( TG_OP = 'DELETE') then
 			insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 
 				 (old.at_key    ,'Testemunha do ato excluida'      	,quote_ident(TG_relname), (SELECT 'Testemunha ' || ph_nome FROM docwin.pessoa_fisica_historico_tb WHERE old.pf_id = ph_id)  ,''		,now()        		,user);
 		end if;	
 	end if;
 
 elseif (quote_ident(TG_relname) = 'p_vadi_tb') then
 	if ( TG_OP = 'INSERT') then	
 		insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 
 				   (new.va_link   ,'Var. Adicional do ato inserida'      ,quote_ident(TG_relname), ''            ,(SELECT 'Var. Adicional ' || ad_tit FROM docwin.p_adic_tb  WHERE new.va_codi = ad_cod)      ,now()            ,user);
 	else 
 		if ( TG_OP = 'DELETE') then
 			insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 
 				 (old.va_link    ,'Var. Adicional do ato excluida'      	,quote_ident(TG_relname), (SELECT 'Var. Adicional ' || ad_tit FROM  docwin.p_adic_tb WHERE old.va_codi = ad_cod)  ,''		,now()        		,user);
 		end if;	
 	end if;
 
     FOR ri IN

         SELECT  column_name

         FROM information_schema.columns

         WHERE

             table_schema = quote_ident(TG_TABLE_SCHEMA)

         AND table_name = quote_ident(TG_TABLE_NAME)

         ORDER BY ordinal_position

     LOOP

 	if ( TG_OP = 'UPDATE') then		

 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_antigo using old;

 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_novo using NEW;

 		if campo_novo <> campo_antigo then

 			insert into docwin.p_log_modificacoes_tb (id      , campo_modificado, tabela                , valor_anterior  , valor_posterior, data_modificacao, usuario) values 

 				        (old.va_link  ,ri.column_name || ' ' || (SELECT 'Var. Adicional ' || ad_tit FROM  docwin.p_adic_tb WHERE old.va_codi = ad_cod) || ' do ato ' || (SELECT 'Livro ' || at_livronome::text || '-' || (CASE WHEN at_livronumero < 0 THEN '*' ELSE at_livronumero::text END) 

 			|| ', Pag. ini. '  || (CASE WHEN at_folhanumero < 0 THEN '*' ELSE at_folhanumero::text END) 

 			|| ' e Pag. final. '  || (CASE WHEN at_folhanumerofinal < 0 THEN '*' ELSE at_folhanumerofinal::text END)

 				FROM docwin.p_atos_tb WHERE at_key=old.va_link)   ,quote_ident(TG_relname), campo_antigo    ,campo_novo      ,now()      ,user);

                 end if;

         end if;       

     END LOOP;

     RETURN NEW;

 

 

 elseif (quote_ident(TG_relname) = 'p_atos_cobrancas_tb') then

 	if ( TG_OP = 'INSERT') then	

 		insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 

 				   (new.at_key   ,'Cobrança do ato inserida'      ,quote_ident(TG_relname), ''            ,(SELECT 'Cobrança ' || descricao FROM docwin.u_ato_padronizado_tb  WHERE new.co_key = id)      ,now()            ,user);

 	else 

 		if ( TG_OP = 'DELETE') then

 			insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 

 				 (old.at_key    ,'Cobranca do ato excluida'      	,quote_ident(TG_relname), (SELECT 'Cobranca ' || descricao FROM  docwin.u_ato_padronizado_tb WHERE old.co_key = id) || CASE WHEN old.ac_ordem > 0 THEN ' vinculada a OS ' || old.ac_ordem ELSE '' END  ,''		,now()        		,user);

 		end if;	

 	end if;

 

     FOR ri IN

         SELECT  column_name

         FROM information_schema.columns

         WHERE

             table_schema = quote_ident(TG_TABLE_SCHEMA)

         AND table_name = quote_ident(TG_TABLE_NAME)

         ORDER BY ordinal_position

     LOOP

 	if ( TG_OP = 'UPDATE') then		

 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_antigo using old;

 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_novo using NEW;

 		if campo_novo <> campo_antigo then

 			insert into docwin.p_log_modificacoes_tb (id      , campo_modificado, tabela                , valor_anterior  , valor_posterior, data_modificacao, usuario) values 

 				        (old.at_key  ,ri.column_name || ' ' || (SELECT 'Cobranca ' || descricao FROM  docwin.u_ato_padronizado_tb WHERE old.co_key = id) || ' do ato ' || (SELECT 'Livro ' || at_livronome::text || '-' || (CASE WHEN at_livronumero < 0 THEN '*' ELSE at_livronumero::text END) 

 			|| ', Pag. ini. '  || (CASE WHEN at_folhanumero < 0 THEN '*' ELSE at_folhanumero::text END) 

 			|| ' e Pag. final. '  || (CASE WHEN at_folhanumerofinal < 0 THEN '*' ELSE at_folhanumerofinal::text END)

 				FROM docwin.p_atos_tb WHERE at_key=old.at_key)   ,quote_ident(TG_relname), campo_antigo    ,campo_novo      ,now()      ,user);

                 end if;

         end if;       

     END LOOP;

     RETURN NEW;

 

 

 

 elseif (quote_ident(TG_relname) = 'p_atos_assentamentos_tb') then

 	if ( TG_OP = 'INSERT') then	

 		insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 

 				   (new.at_key   ,'Assentamento do ato inserida'      ,quote_ident(TG_relname), ''            ,'Assentamento ' || new.aa_titulo     ,now()            ,user);

 	else 

 		if ( TG_OP = 'DELETE') then

 			insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 

 				 (old.at_key    ,'Assentamento do ato excluida'      	,quote_ident(TG_relname),'Assentamento ' || old.aa_titulo,''		,now()        		,user);

 		end if;	

 	end if;

 

     FOR ri IN

         SELECT  column_name

         FROM information_schema.columns

         WHERE

             table_schema = quote_ident(TG_TABLE_SCHEMA)

         AND table_name = quote_ident(TG_TABLE_NAME)

         ORDER BY ordinal_position

     LOOP

 	if ( TG_OP = 'UPDATE') then		

 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_antigo using old;

 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_novo using NEW;

 		if campo_novo <> campo_antigo then

 			insert into docwin.p_log_modificacoes_tb (id      , campo_modificado, tabela                , valor_anterior  , valor_posterior, data_modificacao, usuario) values 

 				        (old.at_key  ,ri.column_name || ' ' || 'Assentamento ' || old.aa_titulo || ' do ato ' || (SELECT 'Livro ' || at_livronome::text || '-' || (CASE WHEN at_livronumero < 0 THEN '*' ELSE at_livronumero::text END) 

 			|| ', Pag. ini. '  || (CASE WHEN at_folhanumero < 0 THEN '*' ELSE at_folhanumero::text END) 

 			|| ' e Pag. final. '  || (CASE WHEN at_folhanumerofinal < 0 THEN '*' ELSE at_folhanumerofinal::text END)

 				FROM docwin.p_atos_tb WHERE at_key=old.at_key)   ,quote_ident(TG_relname), campo_antigo    ,campo_novo      ,now()      ,user);

                 end if;

         end if;       

     END LOOP;

     RETURN NEW;

  

 else

 	if ( TG_OP = 'INSERT') then	

 		insert into docwin.p_log_modificacoes_tb    (id       ,campo_modificado       , tabela                      , valor_anterior, valor_posterior     , data_modificacao, usuario) values 

 				   (new.at_key ,  'Ato inserido (' || new.at_key::text ||')' ,quote_ident(TG_relname)      , ''            ,'Ato inserido'       ,now()            ,user);

 	else 

 		 if ( TG_OP = 'DELETE') then

 			insert into docwin.p_log_modificacoes_tb  (id	, campo_modificado	, tabela		, valor_anterior, valor_posterior	, data_modificacao	, usuario) values 

 					 (old.at_key    ,'Ato excluido (' || new.at_key::text ||')', quote_ident(TG_relname), 'Livro ' || old.at_livronome::text || '-' || (CASE WHEN old.at_livronumero < 0 THEN '*' ELSE old.at_livronumero::text END) 

 			|| ', Pag. ini. '  || (CASE WHEN old.at_folhanumero < 0 THEN '*' ELSE old.at_folhanumero::text END) 

 			|| ' e Pag. final. '  || (CASE WHEN old.at_folhanumerofinal < 0 THEN '*' ELSE old.at_folhanumerofinal::text END),''  		,now()        		,user);

 		 end if;	

     end if;

 end if;

     FOR ri IN

         SELECT  column_name

         FROM information_schema.columns

         WHERE

             table_schema = quote_ident(TG_TABLE_SCHEMA)

         AND table_name = quote_ident(TG_TABLE_NAME)

         ORDER BY ordinal_position

     LOOP

 	if ( TG_OP = 'UPDATE') then		

 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_antigo using old;

 		Execute 'SELECT ($1).' || ri.column_name || '::text' into campo_novo using NEW;

 		if campo_novo <> campo_antigo then

 			insert into docwin.p_log_modificacoes_tb (id      , campo_modificado, tabela                , valor_anterior  , valor_posterior, data_modificacao, usuario) values 

 				        (old.at_key  ,ri.column_name || ' do ato ' || (SELECT 'Livro ' || at_livronome::text || '-' || (CASE WHEN at_livronumero < 0 THEN '*' ELSE at_livronumero::text END) 

 			|| ', Pag. ini. '  || (CASE WHEN at_folhanumero < 0 THEN '*' ELSE at_folhanumero::text END) 

 			|| ' e Pag. final. '  || (CASE WHEN at_folhanumerofinal < 0 THEN '*' ELSE at_folhanumerofinal::text END)

 				FROM docwin.p_atos_tb WHERE at_key=old.at_key)   ,quote_ident(TG_relname), campo_antigo    ,campo_novo      ,now()      ,user);

                 end if;

         end if;       

     END LOOP;

     RETURN NEW;

 END;

  $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION docwin.log_p_ato_tb()
  OWNER TO postgres;
GRANT EXECUTE ON FUNCTION docwin.log_p_ato_tb() TO postgres;
GRANT EXECUTE ON FUNCTION docwin.log_p_ato_tb() TO public;
GRANT EXECUTE ON FUNCTION docwin.log_p_ato_tb() TO docwin_owner;
GRANT EXECUTE ON FUNCTION docwin.log_p_ato_tb() TO escreventes;
GRANT EXECUTE ON FUNCTION docwin.log_p_ato_tb() TO supervisores;


 
CREATE OR REPLACE FUNCTION docwin.release_0_9() RETURNS void as
$$
BEGIN

	IF NOT EXISTS(SELECT column_name FROM information_schema.columns WHERE table_schema='docwin' AND table_name='p_atos_tb' AND column_name='at_textopoder') 
	THEN
		ALTER TABLE docwin.p_atos_tb
			ADD COLUMN at_textopoder text;
	END IF;		
	
	IF NOT EXISTS (SELECT * FROM docwin.aux_func_tb WHERE fu_cod = 641 and fu_mod = 'P')
    THEN
		INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) VALUES (641, 'P', 'Poderes do substabelecimento', 'Fun��o especial. Retorna o texto com o(s) podere(s) do substabelecimento.', 4, 'F', NULL, NULL, NULL, NULL);
	END IF;
	
	IF NOT EXISTS (SELECT * FROM docwin.aux_func_tb WHERE fu_cod = 642 and fu_mod = 'P')
    THEN
		INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) VALUES (642, 'P', 'Revoga��o dos poderes', 'Fun��o especial. Retorna o texto com revoga��o dos poderes.', 4, 'F', NULL, NULL, NULL, NULL);
	END IF;
	
	IF NOT EXISTS (SELECT * FROM docwin.aux_func_tb WHERE fu_cod = 643 and fu_mod = 'P')
    THEN
		INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) VALUES (643, 'P', 'Ren�ncia dos poderes', 'Fun��o especial. Retorna o texto com a ren�ncia dos poderes.', 4, 'F', NULL, NULL, NULL, NULL);
	END IF;
	
	IF NOT EXISTS (SELECT * FROM docwin.aux_func_tb WHERE fu_cod = 48 and fu_mod = 'P')
    THEN
		INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) VALUES (48, 'P', 'Arquivo pasta', 'Campo do banco de dados. Arquivo pasta.', 0, 'T', NULL, NULL, NULL, NULL);
		INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) VALUES (49, 'P', 'Arquivo n�mero','Campo do banco de dados. Arquivo n�mero.', 0, 'T', NULL, NULL, NULL, NULL);
	END IF;
		
	IF NOT EXISTS (SELECT lk_cod FROM docwin.aux_func_lnk_tb WHERE lk_cod=600 AND lk_lnk=16 AND lk_mod='P')
	THEN 
		INSERT INTO docwin.aux_func_lnk_tb(lk_cod, lk_lnk, lk_mod) VALUES (600,16,'P');
	END IF;
	
	IF EXISTS (SELECT * FROM docwin.aux_func_tb WHERE fu_cod = 607 and fu_mod = 'P')
    THEN
		UPDATE  docwin.aux_func_tb SET fu_tit='Assentamentos acess�rios', fu_dsc='Fun��o especial. Retorna o tipo do assentamento acess�rio e seu conte�do.' WHERE fu_cod = 607 and fu_mod = 'P';
	END IF;
	
	IF NOT EXISTS(SELECT column_name FROM information_schema.columns WHERE table_schema='docwin' AND table_name='p_participantes_rogo_tb' AND column_name='ro_rogado') 
	THEN
		ALTER TABLE docwin.p_participantes_rogo_tb ADD COLUMN ro_rogado "char" NOT NULL DEFAULT ' ';
		ALTER TABLE docwin.p_participantes_rogo_tb ALTER COLUMN ro_motivo TYPE text;
		ALTER TABLE docwin.p_participantes_rogo_tb RENAME ro_observacao  TO ro_identificacao;
	END IF;
	
	
END;
$$ LANGUAGE plpgsql VOLATILE;
GRANT EXECUTE ON FUNCTION docwin.release_0_9() TO escreventes;
GRANT EXECUTE ON FUNCTION docwin.release_0_9() TO supervisores;
SELECT docwin.release_0_9();
DROP FUNCTION IF EXISTS docwin.release_0_9();


CREATE INDEX IF NOT EXISTS idx_aux_help_tb
   ON docwin.aux_help_tb USING btree (hlp_codigo ASC NULLS LAST);
   
   
   --iverson
   
CREATE OR REPLACE FUNCTION docwin.colunas() RETURNS void as
$$
BEGIN
	IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
                   WHERE table_schema='docwin' AND table_name='u_item_ato_padronizado_tb' AND column_name='vincula_os' )
    THEN
		ALTER TABLE docwin.u_item_ato_padronizado_tb ADD COLUMN vincula_os boolean DEFAULT true;
    END IF;
END;
$$ LANGUAGE plpgsql VOLATILE;
SELECT docwin.colunas();
DROP FUNCTION IF EXISTS docwin.colunas();

CREATE OR REPLACE FUNCTION docwin.colunas() RETURNS void as
$$
BEGIN
	IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
                   WHERE table_schema='docwin' AND table_name='u_item_ato_padronizado_tb' AND column_name='vincula_os' )
    THEN
		ALTER TABLE docwin.u_item_ato_padronizado_tb ADD COLUMN vincula_os boolean DEFAULT true;
    END IF;
END;
$$ LANGUAGE plpgsql VOLATILE;
SELECT docwin.colunas();
DROP FUNCTION IF EXISTS docwin.colunas();


---0.10

CREATE OR REPLACE FUNCTION docwin.alteracoes() RETURNS void as
$$
BEGIN
	IF NOT EXISTS (SELECT column_name FROM information_schema.columns WHERE table_schema='docwin' AND table_name='aux_ddoc_tb' AND column_name='dd_acervo' )
	THEN
		ALTER TABLE docwin.aux_ddoc_tb ADD COLUMN "dd_acervo" smallint;
	END IF;
	
	IF NOT EXISTS (SELECT column_name FROM information_schema.columns WHERE table_schema='docwin' AND table_name='v_averb_minutas_tb' AND column_name='av_ato_padronizado' )
	THEN
		ALTER TABLE docwin.v_averb_minutas_tb ADD COLUMN "av_ato_padronizado" smallint;
	END IF;
	
	IF NOT EXISTS (SELECT column_name FROM information_schema.columns WHERE table_schema='docwin' AND table_name='v_averb_minutas_tb' AND column_name='av_ato_selagem' )
	THEN
		ALTER TABLE docwin.v_averb_minutas_tb ADD COLUMN "av_ato_selagem" bigint;
	END IF;
	
	IF NOT EXISTS (SELECT column_name FROM information_schema.columns WHERE table_schema='docwin' AND table_name='v_vinculos_minutas_selos_tb')
	THEN
		CREATE TABLE docwin.v_vinculos_minutas_selos_tb
		(
		  vin_tipo integer NOT NULL,
		  vin_serie text,
		  vin_minuta integer NOT NULL,
		  vin_id smallint,
		  CONSTRAINT v_vinculos_pk PRIMARY KEY (vin_tipo, vin_minuta),
		  CONSTRAINT v_vinculos_fkey FOREIGN KEY (vin_minuta)
			  REFERENCES docwin.v_averb_minutas_tb (av_id_minuta_key) MATCH SIMPLE
			  ON UPDATE NO ACTION ON DELETE CASCADE
		)
		WITH (OIDS=FALSE);
		ALTER TABLE docwin.v_vinculos_minutas_selos_tb OWNER TO docwin_owner;
		GRANT ALL ON TABLE docwin.aux_vinculos_ddoc_selos_tb TO supervisores;
		GRANT ALL ON TABLE docwin.aux_vinculos_ddoc_selos_tb TO escreventes;
	END IF;
	
	CREATE TABLE IF NOT EXISTS docwin.aux_servicos_extra_judiciais_tb
	(
	   codservico bigint, 
	   descricao text, 
	   CONSTRAINT aux_servicos_extra_judiciais_tb_pkey PRIMARY KEY (codservico)
	) 
	WITH (
	  OIDS = FALSE
	)
	;
	ALTER TABLE docwin.aux_servicos_extra_judiciais_tb
	  OWNER TO docwin_owner;
	GRANT ALL ON TABLE docwin.aux_servicos_extra_judiciais_tb TO docwin_owner;
	GRANT ALL ON TABLE docwin.aux_servicos_extra_judiciais_tb TO supervisores;
	GRANT SELECT ON TABLE docwin.aux_servicos_extra_judiciais_tb TO escreventes;
	
	IF NOT EXISTS(SELECT * FROM docwin.aux_servicos_extra_judiciais_tb LIMIT 1)
	THEN
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8635, 'SERVI�O DE TESTE DO SELO ELETR�NICO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1600, 'MAGE RCPN 06 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1625, 'NILOPOLIS 04 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1708, 'PETROPOLIS RCPN 01 DISTR 01 CIRC');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1790, 'TRES RIOS RCPN 05 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1815, 'VOLTA REDONDA 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2350, 'BELFORD ROXO 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2368, 'SEROPEDICA 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2664, 'CAPITAL 13 RCPN PA HOSP ROCHA FARIA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1057, 'Posto da Unidade Interligada Hospital Municipal Miguel Couto');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1158, 'CAPITAL RCPN 12 CIRC SUC BARRA DA TIJUCA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1443, 'ANGRA DOS REIS RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1449, 'ANGRA DOS REIS RCPN 02 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1453, 'BARRA MANSA 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8050, 'SAO GONCALO CENTRAL DIST CALC PART AV');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8054, 'DUQUE DE CAXIAS DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8058, 'SAO JOAO DE MERITI CENTRAL DIST CALC PART AVAL');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8060, 'VOLTA REDONDA CENTRAL DIST CALC PART AVAL');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8062, 'NOVA FRIBURGO CENTRAL DIST CALC PART AVAL');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8065, 'BELFORD ROXO DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8066, 'TERESOPOLIS CENTRAL DIST CALC PART AVAL TEST TUTO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8068, 'RIO DAS OSTRAS CENTRAL DIST CALC PART AV TEST TUTO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8070, 'NILOPOLIS CENTRAL DE DIST CALC PART AV TEST TUTO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8072, 'MACAE CENTRAL DIST CALC PART AVAL TEST TUTORIA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8074, 'MARICA CENTRAL DIST CALC PART AVAL TESTAM TUTORIA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8076, 'ITABORAI CENTRAL DIST CALC PART AVAL TESTAM TUTOR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8078, 'BARRA MANSA CENTRAL DIST CALC PART AVAL TEST TUTOR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8080, 'CABO FRIO CENTRAL DIST CALC PART AVAL');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8082, 'ITAPERUNA CENTRAL DIST CALC PART AVAL');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8086, 'ANGRA DOS REIS CENTRAL DIST CALC PART AV TEST TUTO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8088, 'ARARUAMA CENTRAL DIST CALC PART AVAL TEST TUTORIA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8090, 'TRES RIOS CENTRAL DIST CALC PART AVAL TEST TUTORIA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8092, 'MAGE CENTRAL DIST CALC PART AVAL TEST TUTORIA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8094, 'VALENCA CENTRAL DIST CALC PART AVAL TEST TUTORIA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8096, 'RESENDE CENTRAL DIST CALC PART AVAL TEST TUTORIA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8305, 'ITAGUAI CENTRAL DISTR CALC PART AVAL TEST TUTO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8311, 'VASSOURAS CENTRAL DIST CALC PART AV TEST TUTO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1455, 'BARRA MANSA RCPN 03 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(154, 'CAPITAL 01 RCPN');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(729, 'CAPITAL 05 OF DO REG DE DISTRIBUICAO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1533, 'CAMPOS DOS GOYTACAZES DISTRIBUIDOR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1635, 'NITEROI 02 DISTRIBUIDOR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(555, 'Servi�o de Teste');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(556, 'Distribuidor de Teste');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8962, 'SEROPEDICA 02 OF JUSTICA UNID INTER HOSP MAT MUNIC');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(9060, 'NOVA IGUACU-MESQUITA UN.INT. RCPN 2 CIRC 1 DISTR - MATERNIDADE MUNIC.MARIANA BULHOES');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(9066, 'BARRA DO PIRAI RCPN 01 DISTR UNIDADE INTERLIGADA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(9077, 'CAPITAL 08 RCPN UNID INT HOSP GAFFREE E GUINLE');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(9088, 'CAPITAL 03 RCPN UNID INTERL 1 VARA INF JUV IDO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(9089, 'NITEROI RCPN 01 DIST 2 Z JUD UN INT MAT S.FRANCISC');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1517, 'CAMPOS DOS GOYTACAZES 09 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1519, 'CAMPOS DOS GOYTACAZES 13 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1531, 'CAMPOS DOS GOYTACAZES RCPN 17 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1544, 'DUQUE DE CAXIAS 05 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1432, 'VASSOURAS RCPN 2 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1434, 'VASSOURAS RCPN 3 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1435, 'VASSOURAS RCPN 4 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1436, 'VASSOURAS RCPN 5 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2157, 'NOVA IGUACU POSTO DE ATENDIMENTO NOTAS 10 OF JUS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1445, 'ANGRA DOS REIS RCPN 6 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2922, 'CAPITAL POSTO ATENDIMENTO 12A CRCPN - PAULA SOUZA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2925, 'CABO FRIO RCPN 01 DISTR PA HOSPITAL DA MULHER');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1787, 'TRES RIOS RCPN 02 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1545, 'DUQUE DE CAXIAS RCPN 01 DISTR 01 CIRC');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1622, 'NILOPOLIS 03 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1623, 'NILOPOLIS 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1632, 'NITEROI 04 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1634, 'NITEROI RCPN 01 DISTR 06 ZONA JUDIC');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1643, 'NITEROI RCPN 02 DISTR 05 ZONA JUDIC');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1655, 'NOVA FRIBURGO RCPN 04 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1657, 'NOVA FRIBURGO RCPN 06 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1660, 'NOVA FRIBURGO 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1662, 'NOVA FRIBURGO 03 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1663, 'NOVA FRIBURGO 04 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1669, 'NOVA IGUACU RCPN 01 DISTR 02 CIRC');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1675, 'NOVA IGUACU 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1677, 'NOVA IGUACU 04 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1678, 'NOVA IGUACU 05 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1684, 'NOVA IGUACU RCPN 03 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1694, 'PETROPOLIS 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1701, 'PETROPOLIS 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1703, 'PETROPOLIS 04 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1705, 'PETROPOLIS 09 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1707, 'PETROPOLIS 11 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1709, 'PETROPOLIS RCPN 02 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1710, 'PETROPOLIS RCPN 03 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1719, 'NITEROI 03 DISTRIBUIDOR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1727, 'RESENDE 04 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1733, 'RESENDE DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1737, 'RESENDE RCPN 5 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1741, 'SAO GONCALO 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1745, 'SAO GONCALO RCPN 05 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1746, 'SAO GONCALO DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1750, 'SAO GONCALO 05 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1752, 'SAO GONCALO RCPN 04 DISTR 01 CIRC');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1759, 'SAO JOAO DE MERITI 04 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1760, 'SAO JOAO DE MERITI 05 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1773, 'TERESOPOLIS RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1774, 'TERESOPOLIS DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1776, 'TERESOPOLIS 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1777, 'TERESOPOLIS 03 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1793, 'TRES RIOS 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1799, 'VALENCA 03 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1800, 'VALENCA RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1454, 'BARRA MANSA 03 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1498, 'CAMPOS DOS GOYTACAZES 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1501, 'CAMPOS DOS GOYTACAZES 08 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1504, 'CAMPOS DOS GOYTACAZES RCPN 07 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1507, 'CAMPOS DOS GOYTACAZES RCPN 12 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1554, 'ITABORAI 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1561, 'ITABORAI RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1563, 'ITABORAI RCPN 04 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1610, 'MACAE RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1624, 'NILOPOLIS 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1665, 'NOVA FRIBURGO RCPN 03 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1674, 'NOVA IGUACU 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1680, 'NOVA IGUACU 08 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1547, 'DUQUE DE CAXIAS RCPN 02 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1548, 'DUQUE DE CAXIAS RCPN 03 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1562, 'ITABORAI RCPN 03 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1566, 'ITAGUAI 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1513, 'CAMPOS DOS GOYTACAZES 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1459, 'BARRA MANSA 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1461, 'BARRA MANSA RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1726, 'RESENDE 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1728, 'RESENDE RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1779, 'TERESOPOLIS RCPN 03 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1786, 'TRES RIOS RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1791, 'TRES RIOS DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1837, 'SANTO ANTONIO DE PADUA 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2663, 'CAPITAL 13A CRCPN - HOSPITAL PEDRO II - UNIDADE INTERLIGADA ');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2333, 'PINHEIRAL DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2338, 'SAO JOSE DO VALE DO RIO PRETO DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2341, 'ITATIAIA DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2196, 'SAO FRANCISCO DE ITABAPOANA DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1474, 'BARRA DO PIRAI 03 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1475, 'BARRA DO PIRAI RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1481, 'BARRA DO PIRAI 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1482, 'BARRA DO PIRAI 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1490, 'CABO FRIO 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1491, 'CABO FRIO RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1495, 'CABO FRIO DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1499, 'CAMPOS DOS GOYTACAZES 03 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1500, 'CAMPOS DOS GOYTACAZES 07 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1502, 'CAMPOS DOS GOYTACAZES 10 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1505, 'CAMPOS DOS GOYTACAZES RCPN 10 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1509, 'CAMPOS DOS GOYTACAZES RCPN 18 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(458, 'CAPITAL OF DE NOTAS REG CONTR MARITIMOS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2245, 'GUAPIMIRIM DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2251, 'ITALVA DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1401, 'SILVA JARDIM DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1410, 'SUMIDOURO DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1418, 'TRAJANO DE MORAES DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1426, 'VASSOURAS DIST CONT PARTIDOR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1430, 'VASSOURAS 01 OFICIO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1431, 'VASSOURAS RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1441, 'ANGRA DOS REIS 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2357, 'PORTO REAL/QUATIS OFICIO UNICO QUATIS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2358, 'GUAPIMIRIM OFICIO UNICO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(671, 'CGJ SERVICO DE SELOS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(4474, 'OF�CIO �NICO DO MUNICIPIO DE APERIB�');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8148, '25� OF�CIO DE NOTAS DA COMARCA DA CAPITAL');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8149, '26� OF�CIO DE NOTAS DA COMARCA DA CAPITAL');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8150, '27� OF�CIO DE NOTAS DA COMARCA DA CAPITAL');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8153, '30� OF�CIO DE NOTAS DA COMARCA DA CAPITAL');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8155, '32� OF�CIO DE NOTAS DA COMARCA DA CAPITAL');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8157, '34� OF�CIO DE NOTAS DA COMARCA DA CAPITAL');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8158, '35� OF�CIO DE NOTAS DA COMARCA DA CAPITAL');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8159, '36� OF�CIO DE NOTAS DA COMARCA DA CAPITAL');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2361, 'ITALVA OFICIO UNICO ITALVA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2369, 'PINHEIRAL OFICIO UNICO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2373, 'CARAPEBUS/QUISSAMA DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2375, 'CARAPEBUS/QUISSAMA OFICIO UNICO QUISSAMA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2164, 'RIO DAS OSTRAS DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1442, 'ANGRA DOS REIS 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1447, 'ANGRA DOS REIS RCPN 04 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1339, 'RIO BONITO 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1343, 'RIO CLARO RCPN 04 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1345, 'RIO CLARO OFICIO UNICO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1359, 'SANTA MARIA MADALENA DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1362, 'SANTA MARIA MADALENA RCPN 02 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1363, 'SANTA MARIA MADALENA RCPN 03 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1364, 'SANTA MARIA MADALENA RCPN 04 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1372, 'SAO FIDELIS RCPN 03 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1375, 'SAO FIDELIS DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1388, 'SAPUCAIA RCPN 04 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1395, 'SAQUAREMA RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1284, 'MIRACEMA 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1295, 'NATIVIDADE DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1298, 'PARACAMBI 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1980, 'MACAE RCPN 01 DISTR PA BICUDA GRANDE');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1302, 'PARACAMBI RCPN 01 DISTR 01 CIRC');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1308, 'PARAIBA DO SUL RCPN 03 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1322, 'PIRAI RCPN 05 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1323, 'PIRAI 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1223, 'CONCEICAO DE MACABU DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(157, 'CAPITAL 04 RCPN');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(160, 'CAPITAL 07 RCPN');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(156, 'CAPITAL 03 RCPN');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(158, 'CAPITAL 05 RCPN');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(161, 'CAPITAL 08 RCPN');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(163, 'CAPITAL 10 RCPN');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(165, 'CAPITAL RCPN 12 CIRC');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(167, 'CAPITAL 14 RCPN');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1230, 'CORDEIRO DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1239, 'ENGENHEIRO PAULO DE FRONTIN DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1245, 'ITAOCARA 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1246, 'ITAOCARA 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1254, 'LAJE DO MURIAE DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1265, 'MARICA RCPN 03 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1268, 'MENDES RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1858, 'SAO JOAO DA BARRA RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1859, 'SAO JOAO DA BARRA RCPN 05 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1860, 'SAO JOAO DA BARRA RCPN 06 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1866, 'SAO PEDRO DA ALDEIA 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1867, 'SAO PEDRO DA ALDEIA RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1166, 'BOM JARDIM 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1173, 'BOM JESUS DO ITABAPOANA 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1174, 'BOM JESUS DO ITABAPOANA 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1176, 'BOM JESUS DO ITABAPOANA DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8212, '2� REGISTRO CIVIL DE PESSOAS NATURAIS DA COMARCA DA CAPITAL');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8214, '12� REGISTRO CIVIL DE PESSOAS NATURAIS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8239, 'CAPITAL 12 OFICIO DE REGISTRO DE IMOVEIS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(9172, 'NILOPOLIS RCPN 1 DIST UN INT HOSP MAT DOMINGOS L.');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(9176, 'ITABORAI RCPN 01 DISTR UNIDADE INTERLIGADA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(9239, 'CAPITAL 9 RCPN UNID INT INST MED LEG AFRANIO PEIX');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(9289, 'Unidade Interligada no Hospital Municipal Louren�o Jorge - Maternidade Leila Diniz');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(9299, 'UNIDADE INTERLIGADA DO HOSPITAL ESTADUAL PEDRO II');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1180, 'CACHOEIRAS DE MACACU DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1181, 'CACHOEIRAS DE MACACU 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1187, 'RCPN DO 1� DISTRITO DE CAMBUCI');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1192, 'CAMBUCI DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1203, 'CANTAGALO DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1206, 'CARMO RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1814, 'VOLTA REDONDA RCPN 02 CIRC');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1824, 'ARARUAMA RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1825, 'ARARUAMA DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1835, 'SANTO ANTONIO DE PADUA DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1838, 'SANTO ANTONIO DE PADUA RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1803, 'VALENCA 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1804, 'VALENCA 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1214, 'CASIMIRO DE ABREU RCPN 02 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1113, 'NOVA IGUACU 07 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1114, 'ITAGUAI DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1134, 'CAPITAL 14 OF NOTAS SUC REG CAMPO GRANDE');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(162, 'CAPITAL 09 RCPN');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(164, 'CAPITAL 11 RCPN');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(166, 'CAPITAL 13 RCPN');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1794, 'TRES RIOS 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1743, 'SAO GONCALO RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1744, 'SAO GONCALO RCPN 02 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1748, 'SAO GONCALO 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1749, 'SAO GONCALO 04 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1751, 'SAO GONCALO 06 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1758, 'SAO JOAO DE MERITI 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1761, 'SAO JOAO DE MERITI RCPN 03 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1762, 'SAO JOAO DE MERITI DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1764, 'SAO JOAO DE MERITI 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1765, 'SAO JOAO DE MERITI 03 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1772, 'TERESOPOLIS 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1067, 'NITEROI 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1068, 'NITEROI 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1070, 'NITEROI 06 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1073, 'NITEROI 09 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1075, 'NITEROI 11 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1076, 'NITEROI 12 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1078, 'NITEROI 14 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1080, 'NITEROI 16 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1082, 'NITEROI 18 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1083, 'NITEROI 19 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1085, 'CAPITAL 11 RCPN SUCURSAL OLARIA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1086, 'CAPITAL 11 RCPN SUCURSAL BONSUCESSO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1088, 'CAPITAL 11 RCPN SUCURSAL CASCADURA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1096, 'CAPITAL 18 OF NOTAS SUC ILHA DO GOVERNADOR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1161, 'BOM JARDIM 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2924, 'SAPUCAIA RCPN 04 DIST PA VALE DO PIAO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1785, 'TRES RIOS 03 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1683, 'NOVA IGUACU RCPN 01 DISTR 01 CIRC');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1696, 'PETROPOLIS 06 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1698, 'PETROPOLIS RCPN 04 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1704, 'PETROPOLIS 07 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1706, 'PETROPOLIS 10 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1024, 'ARRAIAL DO CABO DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1032, 'CAMPOS DOS GOYTACAZES 12 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1034, 'SAO GONCALO RCPN 03 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1035, 'SAO GONCALO RCPN 04 DISTR 02 CIRC');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1042, 'MAGE RCPN 05 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1711, 'PETROPOLIS DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1729, 'RESENDE RCPN 02 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1734, 'RESENDE 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1735, 'RESENDE 03 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1633, 'NITEROI 05 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1641, 'NITEROI RCPN 01 DISTR 03 ZONA JUDIC');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(702, 'CAPITAL 02 OF DE NOTAS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(706, 'CAPITAL 06 OF DE NOTAS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(708, 'CAPITAL 08 OF DE NOTAS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(710, 'CAPITAL 10 OF DE NOTAS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(715, 'CAPITAL 15 OF DE NOTAS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(717, 'CAPITAL 17 OF DE NOTAS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(719, 'CAPITAL 19 OF DE NOTAS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(721, 'CAPITAL 21 OF DE NOTAS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(723, 'CAPITAL 23 OF DE NOTAS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(726, 'CAPITAL 02 OF DO REG DE DISTRIBUICAO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1644, 'NITEROI 01 DISTRIBUIDOR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1656, 'NOVA FRIBURGO RCPN 05 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1658, 'NOVA FRIBURGO DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1661, 'NOVA FRIBURGO 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1664, 'NOVA FRIBURGO RCPN 01 DISTR 01 CIRC');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1676, 'NOVA IGUACU 03 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1627, 'NILOPOLIS RCPN 02 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(731, 'CAPITAL 07 OF DO REG DE DISTRIBUICAO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(732, 'CAPITAL 08 OF DO REG DE DISTRIBUICAO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(733, 'CAPITAL 09 OF DO REG DE DISTRIBUICAO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(734, 'CAPITAL 01 OF DE REG GERAL DE IMOVEIS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(735, 'CAPITAL 02 OF DE REG GERAL DE IMOVEIS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(737, 'CAPITAL 04 OF DE REG GERAL DE IMOVEIS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(738, 'CAPITAL 05 OF DE REG GERAL DE IMOVEIS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(739, 'CAPITAL 06 OF DE GERAL DE IMOVEIS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(740, 'CAPITAL 07 OF DE REG GERAL DE IMOVEIS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(742, 'CAPITAL 09 OF DE REG GERAL DE IMOVEIS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(743, 'CAPITAL 10 OF DE REG GERAL DE IMOVEIS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(744, 'CAPITAL 11 OF DE REG GERAL DE IMOVEIS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(748, 'CAPITAL 02 OF DE REG DE TIT E DOCUMENTOS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(749, 'CAPITAL 03 OF DE REG DE TIT E DOCUMENTOS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(750, 'CAPITAL 04 OF DE REG DE TIT E DOCUMENTOS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(751, 'CAPITAL 05 OF DE REG DE TIT E DOCUMENTOS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(752, 'CAPITAL 06 OF DE REG DE TIT E DOCUMENTOS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(754, 'CAPITAL 02 OF DE REG DE PROT TITULOS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(755, 'CAPITAL 03 OF DE REG DE PROT TITULOS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(756, 'CAPITAL 04 OF DE REG DE PROT TITULOS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1576, 'ITAPERUNA 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1579, 'ITAPERUNA DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1583, 'ITAPERUNA RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1591, 'MAGE 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1595, 'MAGE DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1597, 'MAGE 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1604, 'MACAE 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1616, 'MACAE DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(728, 'CAPITAL 04 OF DO REG DE DISTRIBUICAO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1033, 'SAQUAREMA RCPN 03 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1036, 'ITAOCARA RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1041, 'NILOPOLIS DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1087, 'CAPITAL 11 RCPN SUCURSAL ENGENHO DE DENTRO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1091, 'CAPITAL 10 OF NOTAS SUC COPACABANA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1094, 'CAPITAL 14 OF NOTAS SUC BONSUCESSO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1098, 'CAPITAL 22 OF DE NOTAS SUC VICENTE DE CARVALHO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1159, 'CAPITAL 18 OF NOTAS SUC REG BARRA TIJUCA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1207, 'CARMO DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1626, 'NILOPOLIS RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1514, 'CAMPOS DOS GOYTACAZES 04 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1518, 'CAMPOS DOS GOYTACAZES 11 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1520, 'CAMPOS DOS GOYTACAZES RCPN 01 DISTR 01 SD');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1522, 'CAMPOS DOS GOYTACAZES RCPN 01 DISTR 03 SD');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1525, 'CAMPOS DOS GOYTACAZES RCPN 04 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1527, 'CAMPOS DOS GOYTACAZES RCPN 09 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1538, 'DUQUE DE CAXIAS 04 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1539, 'DUQUE DE CAXIAS 06 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1540, 'DUQUE DE CAXIAS 07 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1543, 'DUQUE DE CAXIAS 03 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(701, 'CAPITAL 01 OF DE NOTAS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(704, 'CAPITAL 04 OF DE NOTAS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(707, 'CAPITAL 07 OF DE NOTAS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(709, 'CAPITAL 09 OF DE NOTAS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(711, 'CAPITAL 11 OF DE NOTAS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(713, 'CAPITAL 13 OF DE NOTAS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(714, 'CAPITAL 14 OF DE NOTAS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(716, 'CAPITAL 16 OF DE NOTAS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(718, 'CAPITAL 18 OF DE NOTAS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(722, 'CAPITAL 22 OF DE NOTAS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(724, 'CAPITAL 24 OF DE NOTAS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(727, 'CAPITAL 03 OF DO REG DE DISTRIBUICAO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1215, 'CASIMIRO DE ABREU DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1262, 'MARICA 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1264, 'MARICA RCPN 02 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1269, 'MENDES OFICIO UNICO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1276, 'MIGUEL PEREIRA DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1318, 'PARATY DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1324, 'PIRAI RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1326, 'PIRAI DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1385, 'SAPUCAIA RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1392, 'SAPUCAIA DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1394, 'SAQUAREMA OFICIO UNICO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1396, 'SAQUAREMA DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1864, 'SAO PEDRO DA ALDEIA DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1809, 'VALENCA DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1816, 'VOLTA REDONDA 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1742, 'SAO GONCALO 03 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1767, 'SAO JOAO DE MERITI RCPN 02 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1682, 'NOVA IGUACU 10 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1640, 'NITEROI RCPN 01 DISTR 02 ZONA JUDIC');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1569, 'ITAGUAI 03 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1609, 'MACAE 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1516, 'CAMPOS DOS GOYTACAZES 06 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1521, 'CAMPOS DOS GOYTACAZES RCPN 01 DISTR 02 SUBD');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1532, 'CAMPOS DOS GOYTACAZES RCPN 20 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1537, 'DUQUE DE CAXIAS 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1542, 'DUQUE DE CAXIAS 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1549, 'DUQUE DE CAXIAS RCPN 04 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1458, 'BARRA MANSA DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1483, 'BARRA DO PIRAI DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1489, 'CABO FRIO 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1508, 'CAMPOS DOS GOYTACAZES RCPN 15 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(3764, 'CAPITAL 04 RCPN PA INST FERNANDES FIGUEIRA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1415, 'TRAJANO DE MORAES OFICIO UNICO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1429, 'VASSOURAS 02 OFICIO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1350, 'RIO DAS FLORES OFICIO UNICO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1370, 'SAO FIDELIS RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1379, 'SAO SEBASTIAO DO ALTO OFICIO UNICO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1283, 'MIRACEMA DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1306, 'PARAIBA DO SUL RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1221, 'CONCEICAO DE MACABU OFICIO UNICO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1251, 'LAJE DO MURIAE OFICIO UNICO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1270, 'MENDES DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1165, 'BOM JARDIM DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1172, 'BOM JESUS DO ITABAPOANA RCPN 05 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1182, 'CACHOEIRAS DE MACACU 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1110, 'CAPITAL 15 OF NOTAS SUC REG BARRA DA TIJUCA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1072, 'NITEROI 08 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1079, 'NITEROI 15 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1090, 'CAPITAL 05 OF NOTAS SUC CENTRO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2322, 'PATY DO ALFERES OFICIO UNICO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1038, 'DUAS BARRAS RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(736, 'CAPITAL 03 OF DE REG GERAL DE IMOVEIS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(741, 'CAPITAL 08 OF DE REG GERAL DE IMOVEIS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(746, 'CAPITAL 02 OF DE REG DE INTERD E TUTELAS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(753, 'CAPITAL 01 OF DE REG DE PROT TITULOS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2349, 'QUEIMADOS 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(3404, 'NOVA IGUACU RCPN 01 DISTR 02 CIRC PA HOSP DA POSSE');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(3405, 'CAPITAL 11 RCPN PA HOSP GERAL DE BONSUCESSO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(705, 'CAPITAL 05 OF DE NOTAS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(720, 'CAPITAL 20 OF DE NOTAS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(712, 'CAPITAL 12 OF DE NOTAS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1336, 'RIO BONITO 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(703, 'CAPITAL 03 OF DE NOTAS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(725, 'CAPITAL 01 OF DO REG DE DISTRIBUICAO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1074, 'NITEROI 10 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1077, 'NITEROI 13 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2914, 'CAPITAL 09 RCPN PA INST DA MULHER F MAGALHAES');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(3540, 'CAPITAL 04 RCPN UNIDADE INTERLIG MAT ESCOLA UFRJ');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1558, 'ITABORAI DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1568, 'ITAGUAI 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1581, 'ITAPERUNA 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1582, 'ITAPERUNA 03 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1244, 'ITAOCARA DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1446, 'ANGRA DOS REIS DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1460, 'BARRA MANSA 04 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1492, 'CABO FRIO RCPN 02 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1523, 'CAMPOS DOS GOYTACAZES RCPN 02 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1560, 'ITABORAI 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1578, 'ITAPERUNA RCPN 04 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1605, 'MACAE 03 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1639, 'NITEROI RCPN 01 DISTR 01 ZONA JUDIC');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1679, 'NOVA IGUACU 06 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1702, 'PETROPOLIS 03 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1766, 'SAO JOAO DE MERITI RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1778, 'TERESOPOLIS RCPN 02 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1813, 'VOLTA REDONDA RCPN 01 CIRC');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1331, 'PORCIUNCULA DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2918, 'CAPITAL 08 RCPN PA HOSP GERAL DO ANDARAI');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1313, 'PARATY OFICIO UNICO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1338, 'RIO BONITO DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1834, 'SANTO ANTONIO DE PADUA 03 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1854, 'SAO JOAO DA BARRA DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1093, 'CAPITAL 14 OF NOTAS SUC PENHA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2366, 'SAO JOSE DO VALE DO RIO PRETO OFICIO UNICO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2323, 'PORTO REAL/QUATIS OFICIO UNICO PORTO REAL');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2347, 'SEROPEDICA DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2240, 'PORTO REAL/QUATIS DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2191, 'IGUABA GRANDE DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(4448, 'ITAPERUNA OFICIO UNICO SAO JOSE DE UBA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(4450, 'CORDEIRO OFICIO UNICO MACUCO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(4473, 'TRES RIOS OFICIO UNICO COMEND LEVY GASPARIAN');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(4709, 'SAO GONCALO RCPN 04 DISTR 01 C.UNID INTER NS NEVES');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(4710, 'SAO GONCALO RCPN 01 DISTR UN INT HOSP LUIZ PALMIER');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(4711, 'TERESOPOLIS RCPN 01 DISTR PA HOSP DAS CLINICAS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(4713, 'VOLTA REDONDA RCPN 01 CIRC PA HOSP S J BATISTA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(4694, 'ANGRA DOS REIS RCPN 01 DISTR PA HOSP C. DE VILHENA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(4695, 'BELFORD ROXO RCPN DIST. �NICO CASA DE SA�DE E MAT. NOSSA SE. DA GLORIA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(4696, 'CAMPOS DOS GOYTACAZES RCPN 01 DISTR 01 SD PA CANA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(4697, 'CAMPOS DOS GOYTACAZES RCPN 01 DISTR 01 SD PA S.CAS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(4698, 'DUQUE DE CAXIAS RCPN 02 DIST PA HOSP ADAO P. NUNES');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(4701, 'NITEROI RECPN 01 DISTR 02 ZONA JUD PA ALZIRA VIEIR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(4702, 'PET�POLIS RCPN 1� CIRC. DO 1� DIST. C. PROV. HOSP. ALZIRA VARGAS DO AMARAL PEIXOTO ');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(4703, 'QUEIMADOS 03 OF DE JUSTICA PA C S BOM PASTOR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(4704, 'RESENDE RCPN 01 DISTR PA ASSOC PROT MAT INF');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(4706, 'CAPITAL RCPN 12 CIRC PA HOSP LOURENCO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(4693, 'MACAE RCPN 01 DISTR PA HOSP PUB MACAE');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(6737, 'CAPITAL 01 RCPN PA HOSP SERVIDORES DO ESTADO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(6889, 'MESQUITA 2 OFICIO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(6462, 'CAPITAL 04 RCPN PA CASA SAUDE LARANJEIRAS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(6918, 'CANTAGALO OFICIO UNICO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8281, 'CAPITAL 03 RCPN PA HOSP MATER MARIA A B HOLLANDA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(7980, 'CAPITAL 11 RCPN PA COMPLEXO DA PENHA E ALEMAO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8247, 'DUAS BARRAS OFICIO UNICO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8249, 'NATIVIDADE OFICIO UNICO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8251, 'SAO JOAO DA BARRA OFICIO UNICO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8671, 'CAPITAL 14 RCPN UNID. INTERLIGADA HOSP MARISKA RIB');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1592, 'MAGE RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1593, 'MAGE RCPN 02 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1594, 'MAGE RCPN 04 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1598, 'MAGE 03 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1611, 'MACAE RCPN 02 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1614, 'MACAE RCPN 05 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8048, 'DUQUE DE CAXIAS RCPN 01 DIST 01 CIRC P.HOSP.MOACYR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8230, 'CAPITAL 03 RCPN PA HOSP SOUZA AGUIAR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8313, 'NOVA IGUA�U-MESQUITA 01 OF. UNIDADE INTERLIGADA HOSPITAL DA M�E');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8295, 'NOVA IGUACU NUCLEO DE AUTUACAO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(7497, 'SILVA JARDIM OF UNICO MUNIC SILVA JARDIM');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8235, 'MIGUEL PEREIRA OFICIO UNICO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8236, 'PARAIBA DO SUL OFICIO UNICO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8237, 'SAO FIDELIS OFICIO UNICO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8238, 'SAPUCAIA OFICIO UNICO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(7515, 'SAO JOAO DE MERITI RCPN 01 DISTR PA HOSP MULHER');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8246, 'MANGARATIBA OFICIO UNICO DO MUNICIP MANGARATIBA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8757, 'SAO JOAO DE MERITI RCPN 01 DISTR UN.INT.CASA SAUDE');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1647, 'NITEROI RCPN 1 DISTR 7 Z JUDICIARIA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1654, 'NOVA FRIBURGO RCPN 1 DISTR 2 CIRC');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1666, 'NOVA FRIBURGO RCPN 2 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1670, 'NOVA IGUACU RCPN 02 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1681, 'NOVA IGUACU 09 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1570, 'ITAGUAI RCPN 02 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1571, 'ITAGUAI RCPN 3 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(745, 'CAPITAL 01 OF DE REG DE INTERD E TUTELAS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1577, 'ITAPERUNA RCPN 3 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1584, 'ITAPERUNA RCPN 2 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1585, 'ITAPERUNA RCPN 05 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1325, 'PIRAI RCPN 2 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1330, 'PORCIUNCULA RCPN 02 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1333, 'PORCIUNCULA RCPN 03 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1222, 'CONCEICAO DE MACABU RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1225, 'CONCEICAO DE MACABU RCPN 02 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1228, 'CORDEIRO RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(155, 'CAPITAL RCPN 02 CIRC');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(159, 'CAPITAL RCPN 06 CIRC');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1933, 'VALENCA POSTO DE ATENDIMENTO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1229, 'CORDEIRO RCPN 02 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1232, 'DUAS BARRAS 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1233, 'DUAS BARRAS RCPN 2 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1235, 'DUAS BARRAS 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1238, 'ENGENHEIRO PAULO DE FRONTIN RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1240, 'ENGENHEIRO PAULO DE FRONTIN RCPN 2 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1243, 'ITAOCARA RCPN 2 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1248, 'ITAOCARA RCPN 4 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1249, 'ITAOCARA RCPN 5 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1250, 'ITAOCARA RCPN 3 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1253, 'LAJE DO MURIAE RCPN DISTRITO UNICO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1256, 'MANGARATIBA RCPN 2 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1259, 'MANGARATIBA RCPN 3 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1273, 'MIGUEL PEREIRA RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1275, 'MIGUEL PEREIRA RCPN 03 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1954, 'CANTAGALO POSTO DE ATENDIMENTO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1856, 'SAO JOAO DA BARRA 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1857, 'SAO JOAO DA BARRA 03 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1863, 'SAO PEDRO DA ALDEIA RCPN 2 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1599, 'MAGE RCPN 3 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1606, 'MACAE RCPN 7 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1607, 'MACAE RCPN 8 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1613, 'MACAE RCPN 04 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1089, 'CAPITAL RCPN 12 CIRC SUC PENHA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1100, 'CAPITAL 24 OF NOTAS SUC COPACABANA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1103, 'CAPITAL POSTO ATENDIMENTO 7 CIRC RCPN');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1524, 'CAMPOS DOS GOYTACAZES RCPN 03 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1529, 'CAMPOS DOS GOYTACAZES RCPN 14 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1530, 'CAMPOS DOS GOYTACAZES RCPN 16 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1040, 'ITAGUAI RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1092, 'CAPITAL 14 OF NOTAS SUC IPANEMA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1097, 'CAPITAL 22 OF NOTAS SUC TIJUCA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1115, 'MANGARATIBA DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1129, 'CAPITAL 14 RCPN SUCURSAL BANGU');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1162, 'BOM JARDIM RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1179, 'CACHOEIRAS DE MACACU RCPN 02 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1183, 'CACHOEIRAS DE MACACU RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1188, 'CAMBUCI RCPN 02 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1194, 'CAMBUCI RCPN 05 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1208, 'CARMO OFICIO UNICO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1546, 'DUQUE DE CAXIAS 2 CIRC 1 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1257, 'MANGARATIBA 2 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1274, 'MIGUEL PEREIRA RCPN 2 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1376, 'SAO FIDELIS 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1383, 'SAO SEBASTIAO DO ALTO RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1952, 'CAMBUCI POSTO DE ATENDIMENTO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1668, 'NOVA IGUACU 11 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1526, 'CAMPOS DOS GOYTACAZES RCPN 08 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1478, 'BARRA DO PIRAI RCPN 03 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1403, 'SILVA JARDIM RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1409, 'SUMIDOURO 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1420, 'TRAJANO DE MORAES RCPN 2 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1425, 'VASSOURAS RCPN 6 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1320, 'PIRAI RCPN 03 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1167, 'BOM JARDIM RCPN 3 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1169, 'BOM JESUS DO ITABAPOANA RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1170, 'BOM JESUS DO ITABAPOANA RCPN 2 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1171, 'BOM JESUS DO ITABAPOANA RCPN 04 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1175, 'BOM JESUS DO ITABAPOANA RCPN 03 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1185, 'CACHOEIRAS DE MACACU RCPN 3 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1186, 'CAMBUCI 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1189, 'CAMBUCI RCPN 03 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1191, 'CAMBUCI RCPN 6 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1193, 'CAMBUCI 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1196, 'CANTAGALO 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1199, 'CANTAGALO RCPN 02 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1200, 'CANTAGALO RCPN 03 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1201, 'CANTAGALO RCPN 04 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1202, 'CANTAGALO RCPN 05 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1841, 'SANTO ANTONIO DE PADUA RCPN 6 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1842, 'SANTO ANTONIO DE PADUA RCPN 7 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1843, 'SANTO ANTONIO DE PADUA RCPN 8 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1845, 'SANTO ANTONIO DE PADUA RCPN 3 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1846, 'SANTO ANTONIO DE PADUA RCPN 4 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1851, 'SAO JOAO DA BARRA RCPN 2 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1853, 'SAO JOAO DA BARRA RCPN 4 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1806, 'VALENCA RCPN 3 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1807, 'VALENCA RCPN 5 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1808, 'VALENCA RCPN 6 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1064, 'RIO CLARO RCPN 05 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1210, 'CARMO RCPN 3 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1211, 'CARMO RCPN 2 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1213, 'CASIMIRO DE ABREU 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1216, 'CASIMIRO DE ABREU 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1217, 'CASIMIRO DE ABREU RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1788, 'TRES RIOS RCPN 03 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1685, 'NOVA IGUACU RCPN 05 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1695, 'PETROPOLIS 05 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1697, 'PETROPOLIS 8 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1699, 'PETROPOLIS RCPN 05 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1013, 'NITEROI 10 OF DE JUSTICA SUC ICARAI');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1014, 'NITEROI 17 OF DE JUSTICA SUC INGA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1037, 'ITAPERUNA RCPN 6 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2915, 'CAPITAL 01 RCPN PA HOSP MAT OSWALDO NAZARETH');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1712, 'PETROPOLIS RCPN 1 DISTR 2 CIRC');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1730, 'RESENDE RCPN 3 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1732, 'RESENDE RCPN 8 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1642, 'NITEROI RCPN 01 DISTR 04 ZONA JUDIC');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1448, 'ANGRA DOS REIS RCPN 3 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1227, 'CORDEIRO OFICIO UNICO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1234, 'DUAS BARRAS DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1237, 'ENGENHEIRO PAULO DE FRONTIN OFICIO UNICO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1261, 'MARICA 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1263, 'MARICA RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1266, 'MARICA DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1281, 'MIRACEMA 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1299, 'PARACAMBI DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1300, 'PARACAMBI 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1346, 'RIO CLARO RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1347, 'RIO CLARO RCPN 02 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1349, 'RIO CLARO RCPN 3 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1351, 'RIO DAS FLORES RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1354, 'RIO DAS FLORES RCPN 2 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1355, 'RIO DAS FLORES RCPN 3 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1361, 'SANTA MARIA MADALENA 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1367, 'SANTA MARIA MADALENA RCPN 5 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1369, 'SAO FIDELIS 03 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1371, 'SAO FIDELIS RCPN 2 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1373, 'SAO FIDELIS RCPN 04 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1374, 'SAO FIDELIS RCPN 05 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1377, 'SAO FIDELIS 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1380, 'SAO SEBASTIAO DO ALTO RCPN 02 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1390, 'SAPUCAIA RCPN 2 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1391, 'SAPUCAIA RCPN 3 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1282, 'MIRACEMA RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1286, 'MIRACEMA 3 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1287, 'MIRACEMA RCPN 2 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1288, 'MIRACEMA RCPN 3 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1291, 'NATIVIDADE 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1292, 'NATIVIDADE RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1293, 'NATIVIDADE RCPN 02 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1294, 'NATIVIDADE RCPN 03 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1979, 'ITAPERUNA RCPN 01 DISTR PA BOA VENTURA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1981, 'VALENCA POSTO DE ATENDIMENTO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1301, 'PARACAMBI RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1304, 'PARAIBA DO SUL 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1305, 'PARAIBA DO SUL 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1307, 'PARAIBA DO SUL RCPN 2 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1309, 'PARAIBA DO SUL RCPN 4 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1314, 'PARATY RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1316, 'PARATY RCPN 2 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1451, 'ANGRA DOS REIS POSTO DE ATENDIMENTO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1340, 'RIO BONITO RCPN 02 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1356, 'RIO DAS FLORES RCPN 4 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1360, 'SANTA MARIA MADALENA 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1365, 'SANTA MARIA MADALENA RCPN 06 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1290, 'NATIVIDADE 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1332, 'PORCIUNCULA RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1258, 'MANGARATIBA RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1164, 'BOM JARDIM RCPN 04 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2153, 'BARRA MANSA POSTO ATEND NOSSA SRA AMPARO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2185, 'CAPITAL POSTO DE ATENDIMENTO 2A CRCPN');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1190, 'CAMBUCI RCPN SAO JOSE DE UBA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1197, 'CANTAGALO 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1219, 'CASIMIRO DE ABREU RCPN 01 DISTR PA RIO DAS OSTRAS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1142, 'ILHA DO GOVERNADOR REGIONAL 1 CIRC RCPN');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1101, 'CAPITAL POSTO ATENDIMENTO 3 CIRC RCPN');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(3415, 'ITABORAI RCPN 01 DISTR PA HOSP DES LEAL JUNIOR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1321, 'PIRAI RCPN 4 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1844, 'SANTO ANTONIO DE PADUA RCPN 2 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1116, 'MANGARATIBA 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1117, 'MANGARATIBA RCPN 4 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1124, 'CAPITAL 23 OF NOTAS SUC REG JACAREPAGUA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1130, 'BANGU REGIONAL P ATEND 14 CIRC RCPN');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1071, 'NITEROI 7 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1081, 'NITEROI 17 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1310, 'PARAIBA DO SUL DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1319, 'PIRAI 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1329, 'PORCIUNCULA OFICIO UNICO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1337, 'RIO BONITO RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1344, 'RIO CLARO DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1352, 'RIO DAS FLORES DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1358, 'SANTA MARIA MADALENA RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1381, 'SAO SEBASTIAO DO ALTO DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1387, 'SAPUCAIA 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1095, 'CAPITAL 16 OF NOTAS SUC LEBLON');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1099, 'CAPITAL 23 OF NOTAS SUC TIJUCA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1104, 'CAPITAL RCPN 12 CIRC PA LARGO DO TANQUE');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1143, 'CAPITAL 08 OF DE NOTAS SUC ILHA DO GOVERNADOR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1160, 'CAPITAL 24 OF NOTAS SUC BARRA DA TIJUCA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(3895, 'NOVA IGUACU 01 OF DE JUSTICA PA DE NOTAS AUSTIN');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(3932, 'PETROPOLIS 04 OF JUSTICA PA DE REG IMOVEIS POSSE');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2916, 'CAPITAL RCPN 01 CIRC PA HOSP PRO MATRE');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1278, 'MIGUEL PEREIRA 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1317, 'PARATY RCPN 3 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1386, 'SAPUCAIA 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1400, 'SILVA JARDIM 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1444, 'ANGRA DOS REIS RCPN 5 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1479, 'BARRA DO PIRAI RCPN 04 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1731, 'RESENDE RCPN 06 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2364, 'JAPERI 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2923, 'CAPITAL RCPN 06 CIRC PA HOSP SOUZA AGUIAR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1163, 'BOM JARDIM RCPN 2 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1198, 'CANTAGALO RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1277, 'MIGUEL PEREIRA 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1567, 'ITAGUAI RCPN 4 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1827, 'ARARUAMA RCPN 02 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1417, 'TRAJANO DE MORAES RCPN 3 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1464, 'BARRA MANSA RCPN 7 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1480, 'BARRA DO PIRAI RCPN 5 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(3560, 'TERESOPOLIS RCPN 03 DISTR PA SEDE');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2376, 'ITABORAI RCPN 01 DISTR PA CABUCU');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(4636, 'CAMBUCI OFICIO UNICO MUNICIPIO DE SAO JOSE DE UBA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(6706, 'CAPITAL POSTO DE ATENDIMENTO 12A. CRCPN - PENHA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(7981, 'CAPITAL RCPN 12 P.A. COMPLEXO DA PENHA E ALEMAO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1456, 'BARRA MANSA RCPN 5 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1556, 'ITABORAI RCPN 05 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1612, 'MACAE RCPN 3 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1615, 'MACAE RCPN 6 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1671, 'NOVA IGUACU RCPN 06 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1555, 'ITABORAI RCPN 02 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1557, 'ITABORAI RCPN 6 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1463, 'BARRA MANSA RCPN 2 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1465, 'BARRA MANSA RCPN 4 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1736, 'RESENDE RCPN 04 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1789, 'TRES RIOS RCPN 04 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1852, 'SAO JOAO DA BARRA RCPN 3 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1476, 'BARRA DO PIRAI 02 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1493, 'CABO FRIO RCPN 3 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1494, 'ARRAIAL DO CABO RCPN DISTRITO UNICO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1503, 'CAMPOS DOS GOYTACAZES RCPN 05 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1506, 'CAMPOS DOS GOYTACAZES RCPN 11 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1457, 'BARRA MANSA RCPN 6 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1402, 'SILVA JARDIM 1 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1405, 'SILVA JARDIM RCPN 3 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1406, 'SILVA JARDIM RCPN 4 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1407, 'SILVA JARDIM RCPN 2 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1411, 'SUMIDOURO 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1413, 'SUMIDOURO DISTRITO UNICO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1416, 'TRAJANO DE MORAES RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1421, 'TRAJANO DE MORAES RCPN 4 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1422, 'TRAJANO DE MORAES RCPN 5 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1424, 'VASSOURAS 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1427, 'VASSOURAS AVALIADOR JUDICIAL');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1428, 'VASSOURAS 02 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1801, 'VALENCA RCPN 4 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1805, 'VALENCA RCPN 02 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1817, 'VOLTA REDONDA DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1823, 'ARARUAMA 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1826, 'ARARUAMA 02 OF JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1828, 'ARARUAMA RCPN 03 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1836, 'SANTO ANTONIO DE PADUA 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1839, 'SANTO ANTONIO DE PADUA RCPN 05 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1855, 'SAO JOAO DA BARRA 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1865, 'SAO PEDRO DA ALDEIA 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1874, 'BELFORD ROXO RCPN DISTRITO UNICO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1875, 'BELFORD ROXO CENTRAL DIST CALC PART AV TEST TUTO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1970, 'RIO BONITO RCPN 01 DISTR PA BOA ESPERANCA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2214, 'QUEIMADOS DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2243, 'PATY DO ALFERES DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2248, 'ARMACAO DOS BUZIOS DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2321, 'QUEIMADOS 03 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2326, 'BELFORD ROXO 03 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2335, 'QUEIMADOS 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2344, 'JAPERI DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2351, 'BELFORD ROXO 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2353, 'ARRAIAL DO CABO OFICIO UNICO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2354, 'RIO DAS OSTRAS OFICIO UNICO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2355, 'IGUABA GRANDE OFICIO UNICO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2356, 'SAO FRANCISCO DE ITABAPOANA OFICIO UNICO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2359, 'ARMACAO DOS BUZIOS OFICIO UNICO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2360, 'ITALVA OFICIO UNICO CARDOSO MOREIRA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2367, 'SEROPEDICA 01 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2370, 'ITATIAIA OFICIO UNICO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2374, 'CARAPEBUS/QUISSAMA OFICIO UNICO CARAPEBUS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2378, 'PETROPOLIS CENTRAL DE RECEBIMENTO DE DOC. - CERD');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2652, 'TANGUA OFICIO UNICO TANGUA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2665, 'CAPITAL 14 RCPN PA HOSP ALBERT SCHWEITZER');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2697, 'SAQUAREMA POSTO DE ATEND RCPN 2. DISTRITO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2750, 'SAO JOAO DE MERITI UNID INTERLIGADA RCPN 01 DISTR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2917, 'CAPITAL 05 RCPN PA HOSP MIGUEL COUTO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2919, 'CAPITAL 10 RCPN PA HOSP MAT CARMELA DUTRA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2920, 'CAPITAL 14 RCPN UIS HERCULANO PINHEIRO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(2921, 'CAPITAL RCPN 12 CIRC PA HOSP MAT ALEXANDER FLEMING');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(3406, 'DUQUE DE CAXIAS RCPN 04 DISTR PA MAT XEREM');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(3418, 'TRES RIOS OFICIO UNICO AREAL');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(3421, 'PETROPOLIS RCPN 02 DISTR PA HOSP ALCIDES CARNEIRO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(3931, 'NOVA FRIBURGO RCPN 01 DISTR PA MAT NOVA FRIBURGO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(4410, 'CAPITAL 01 RCPN PA EDIF CANDIDO MENDES-CENTRO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(4456, 'NATIVIDADE OFICIO UNICO VARRE E SAI');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(4700, 'NITEROI RECPN 01 DISTR 03 ZONA JUD PA AZEVEDO LIMA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(4705, 'RIO DAS OSTRAS OFICIO UNICO PA HOSP RIO DAS OSTRAS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(4707, 'BARRA MANSA RCPN 01 DISTR HOSP TERESA S. DE MOURA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(4712, 'TRES RIOS RCPN 01 DISTR UN.INTERL. HOSP NS CONCEIC');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(6707, 'CAPITAL POSTO DE ATEND. 12 CRCPN - BARRA DA TIJUCA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(6886, 'MESQUITA 1 OFICIO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(6913, 'NITEROI P.A. 3 ZONA 1 DISTR HOSP UNI ANTONIO PEDRO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(6926, 'JAPERI OFICIO UNICO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(6934, 'CASIMIRO DE ABREU OFICIO UNICO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8056, 'NOVA IGUACU DCP');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8084, 'RIO BONITO CENTRAL DIST CALC PART AVAL TEST TUTOR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8151, '28� OF�CIO DE NOTAS DA COMARCA DA CAPITAL');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8154, '31� OF�CIO DE NOTAS DA COMARCA DA CAPITAL');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8156, '33� OF�CIO DE NOTAS DA COMARCA DA CAPITAL');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8213, '6� REGISTRO CIVIL DE PESSOAS NATURAIS DA COMARCA DA CAPITAL');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8248, 'CAMBUCI OFICIO UNICO MUNICIPIO CAMBUCI');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8250, 'SANTA MARIA MADALENA OFICIO UNICO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8252, 'SUMIDOURO OFICIO UNICO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8334, 'NILOPOLIS RCPN 1 DISTR. P.A. HOSP. ESTAD. VEREADOR');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8697, 'CAPITAL 14 RCPN UNID. INTERLIGADA HOSP RONALDO GAZ');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8887, 'CAPITAL 12 C RCPN  MATERNIDADE PERINATAL DA BARRA DA TIJUCA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(9095, 'ARARUAMA RCPN I DISTR UN INT MATERN PUB ESTADUAL');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(9134, 'SAQUAREMA RCPN 2 DISTR UN INT HOSPITAL ESTADUAL LAGOS NOSSA SENHORA DE NAZARETH');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(457, 'CAPITAL OF DO REG CIVIL DAS PESSOAS JURIDICAS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(8152, '29� OF�CIO DE NOTAS DA COMARCA DA CAPITAL');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1069, 'NITEROI 03 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(747, 'CAPITAL 01 OF DE REG DE TIT E DOCUMENTOS');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1515, 'CAMPOS DOS GOYTACAZES 05 OF DE JUSTICA');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(730, 'CAPITAL 06 OF DO REG DE DISTRIBUICAO');
	  INSERT INTO docwin.aux_servicos_extra_judiciais_tb VALUES(1397, 'SAQUAREMA RCPN 02 DISTR');
  END IF;
  
  IF NOT EXISTS (SELECT column_name FROM information_schema.columns WHERE table_schema='docwin' AND table_name='n_pnas_tb' AND column_name='pn_114' )
	THEN
		ALTER TABLE docwin.n_pnas_tb ADD COLUMN pn_114 text; -- rg
		ALTER TABLE docwin.n_pnas_tb ADD COLUMN pn_115 text; -- emissor
		ALTER TABLE docwin.n_pnas_tb ADD COLUMN pn_116 date; -- data
		ALTER TABLE docwin.n_pnas_tb ADD COLUMN pn_451 text; -- senten�a/mandato		
		
		INSERT INTO docwin.aux_func_tb VALUES (114, 'N', 'N�mero do RG do registrado', 'Campo do banco de dados. Neste campo � armazenado o n�mero do RG do registrado.', 0, 'T', 20, NULL, NULL, NULL);	
		INSERT INTO docwin.aux_func_tb VALUES (115, 'N', '�rg�o emissor do RG do registrado', 'Campo do banco de dados. Neste campo � armazenado o �rg�o emissor do RG do registrado.', 0, 'T', 10, NULL, NULL, NULL);	
		INSERT INTO docwin.aux_func_tb VALUES (116, 'N', 'Data de emiss�o do RG do registrado', 'Campo do banco de dados. Neste campo � armazenado a data de emiss�o do RG do registrado.', 0, 'T', 10, '99/99/9999', NULL, NULL);	
		INSERT INTO docwin.aux_func_tb VALUES (451, 'N', 'N� da senten�a/mandato', 'Campo do banco de dados. Neste campo � armazenado o n�mero da senten�a/mandato.', 0, 'T', NULL, NULL, NULL, NULL);	
				
	END IF;
	
	IF NOT EXISTS (SELECT column_name FROM information_schema.columns WHERE table_schema='docwin' AND table_name='n_pnas_detalhes_tb' AND column_name='gerou_cpf' )
	THEN
		ALTER TABLE docwin.n_pnas_detalhes_tb ADD COLUMN gerou_cpf boolean DEFAULT false;
	END IF;

END;
$$ LANGUAGE plpgsql VOLATILE;
SELECT docwin.alteracoes();
DROP FUNCTION IF EXISTS docwin.alteracoes();	


CREATE OR REPLACE FUNCTION docwin.alteracoes_r010() RETURNS void as
$$
BEGIN
	IF NOT EXISTS (SELECT column_name FROM information_schema.columns WHERE table_schema='docwin' AND table_name='n_pnas_tb' AND column_name='pn_300' )
	THEN
		ALTER TABLE docwin.n_pnas_tb ADD COLUMN pn_300 text;
			COMMENT ON COLUMN docwin.n_pnas_tb.pn_300 IS 'Nro do protocolo';
			
		INSERT INTO docwin.aux_func_tb VALUES (300, 'N', 'N� do protocolo', 'Campo do banco de dados. Neste campo � armazenado o n�mero do protocolo.', 0, 'T', 15, NULL, NULL, NULL);	
			
		PERFORM docwin.inserealterahelp('N','C','C300','

   Neste campo voc� inclui o n�mero
   do   protocolo  do  registro  de
   nascimento.','N� do protocolo');
   
		
	END IF;
	
	IF NOT EXISTS (SELECT column_name FROM information_schema.columns WHERE table_schema='docwin' AND table_name='o_pobi_tb' AND column_name='po_300' )
	THEN
		ALTER TABLE docwin.o_pobi_tb ADD COLUMN po_300 text;
			COMMENT ON COLUMN docwin.o_pobi_tb.po_300 IS 'Nro do protocolo';
			
		INSERT INTO docwin.aux_func_tb VALUES (300, 'O', 'N� do protocolo', 'Campo do banco de dados. Neste campo � armazenado o n�mero do protocolo.', 0, 'T', 15, NULL, NULL, NULL);	
			
		PERFORM docwin.inserealterahelp('O','C','C300','

   Neste campo voc� inclui o n�mero
   do   protocolo  do  registro  de
   nascimento.','N� do protocolo');
   
		
	END IF;
	
END;
$$ LANGUAGE plpgsql VOLATILE;
SELECT docwin.alteracoes_r010();
DROP FUNCTION IF EXISTS docwin.alteracoes_r010();	



GRANT ALL ON TABLE docwin.v_vinculos_minutas_selos_tb TO docwin_owner;
GRANT ALL ON TABLE docwin.v_vinculos_minutas_selos_tb TO supervisores;
GRANT ALL ON TABLE docwin.v_vinculos_minutas_selos_tb TO escreventes;

CREATE OR REPLACE FUNCTION docwin.colunas() RETURNS void as
$$
BEGIN
	IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
                   WHERE table_schema='docwin' AND table_name='u_item_ordem_servico_tb' AND column_name='gratuito' )
    THEN
		ALTER TABLE docwin.u_item_ordem_servico_tb ADD COLUMN gratuito boolean DEFAULT false;
    END IF;
END;
$$ LANGUAGE plpgsql VOLATILE;
SELECT docwin.colunas();
DROP FUNCTION IF EXISTS docwin.colunas();




CREATE OR REPLACE FUNCTION docwin.colunas() RETURNS void as
$$
BEGIN


	IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
                   WHERE table_schema='docwin' AND table_name='u_item_ordem_servico_tb' AND column_name='grupo')
    THEN
		ALTER TABLE docwin.u_item_ordem_servico_tb ADD COLUMN grupo smallint;	
		UPDATE docwin.u_item_ordem_servico_tb set grupo = 1;
    END IF;
	
END;
$$ LANGUAGE plpgsql VOLATILE;
GRANT EXECUTE ON FUNCTION docwin.colunas() TO escreventes;
GRANT EXECUTE ON FUNCTION docwin.colunas() TO supervisores;
SELECT docwin.colunas();
DROP FUNCTION IF EXISTS docwin.colunas();
 

 
GRANT ALL ON TABLE docwin.e_prin_tb TO docwin_owner;
GRANT ALL ON TABLE docwin.e_prin_tb TO supervisores;
GRANT ALL ON TABLE docwin.e_prin_tb TO escreventes;

UPDATE docwin.aux_preferencias_tb SET valor='0.10' WHERE nome='inf_bd_rel';

CREATE OR REPLACE FUNCTION docwin.alteracoes_r010() RETURNS void as
$$
BEGIN
	IF NOT EXISTS (SELECT column_name FROM information_schema.columns WHERE table_schema='docwin' AND table_name='n_pnas_tb' AND column_name='pn_300' )
	THEN
		ALTER TABLE docwin.n_pnas_tb ADD COLUMN pn_300 text;
			COMMENT ON COLUMN docwin.n_pnas_tb.pn_300 IS 'Nro do protocolo';
			
		INSERT INTO docwin.aux_func_tb VALUES (300, 'N', 'N� do protocolo', 'Campo do banco de dados. Neste campo � armazenado o n�mero do protocolo.', 0, 'T', 15, NULL, NULL, NULL);	
			
		PERFORM docwin.inserealterahelp('N','C','C300','

   Neste campo voc� inclui o n�mero
   do   protocolo  do  registro  de
   nascimento.','N� do protocolo');
   
		
	END IF;
	
	IF NOT EXISTS (SELECT column_name FROM information_schema.columns WHERE table_schema='docwin' AND table_name='o_pobi_tb' AND column_name='po_300' )
	THEN
		ALTER TABLE docwin.o_pobi_tb ADD COLUMN po_300 text;
			COMMENT ON COLUMN docwin.o_pobi_tb.po_300 IS 'Nro do protocolo';
			
		INSERT INTO docwin.aux_func_tb VALUES (300, 'O', 'N� do protocolo', 'Campo do banco de dados. Neste campo � armazenado o n�mero do protocolo.', 0, 'T', 15, NULL, NULL, NULL);	
			
		PERFORM docwin.inserealterahelp('O','C','C300','

   Neste campo voc� inclui o n�mero
   do   protocolo  do  registro  de
   nascimento.','N� do protocolo');
   
		
	END IF;
	
END;
$$ LANGUAGE plpgsql VOLATILE;
SELECT docwin.alteracoes_r010();
DROP FUNCTION IF EXISTS docwin.alteracoes_r010();	



GRANT ALL ON TABLE docwin.v_vinculos_minutas_selos_tb TO docwin_owner;
GRANT ALL ON TABLE docwin.v_vinculos_minutas_selos_tb TO supervisores;
GRANT ALL ON TABLE docwin.v_vinculos_minutas_selos_tb TO escreventes;

CREATE OR REPLACE FUNCTION docwin.colunas() RETURNS void as
$$
BEGIN
	IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
                   WHERE table_schema='docwin' AND table_name='u_item_ordem_servico_tb' AND column_name='gratuito' )
    THEN
		ALTER TABLE docwin.u_item_ordem_servico_tb ADD COLUMN gratuito boolean DEFAULT false;
    END IF;
END;
$$ LANGUAGE plpgsql VOLATILE;
SELECT docwin.colunas();
DROP FUNCTION IF EXISTS docwin.colunas();


--0.11

CREATE OR REPLACE FUNCTION docwin.alteracoes_r011() RETURNS void as
$$
BEGIN
	IF NOT EXISTS (SELECT column_name FROM information_schema.columns WHERE table_schema='docwin' AND table_name='o_pobi_tb' AND column_name='po_110' )
	THEN
		ALTER TABLE docwin.o_pobi_tb ADD COLUMN po_110 text;
			COMMENT ON COLUMN docwin.o_pobi_tb.po_110 IS 'N�mero do Processo';
			
		INSERT INTO docwin.aux_func_tb VALUES (110, 'O', 'N� do processo', 'Campo do banco de dados. Neste campo � armazenado o n�mero do processo ou senten�a judicial, para os registros feitos via mandado.', 0, 'T', 80, NULL, NULL, NULL);	
			
		PERFORM docwin.inserealterahelp('O','C','C300','

   Neste campo voc� inclui o n�mero
   do processo ou mandado judicial.','N� do processo');
   	
	END IF;	
	
	IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
                   WHERE table_schema='docwin' AND table_name='u_item_ordem_servico_tb' AND column_name='id_ato_padronizado')
    THEN
		ALTER TABLE docwin.u_item_ordem_servico_tb ADD COLUMN id_ato_padronizado smallint;	
 
    END IF;
	
	IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
                   WHERE table_schema='docwin' AND table_name='u_item_ordem_servico_tb' AND column_name='desc_ato_padronizado')
    THEN
		ALTER TABLE docwin.u_item_ordem_servico_tb ADD COLUMN desc_ato_padronizado text;	
    END IF;
	
	ALTER TABLE docwin.e_socios_inter_comer_tb DROP CONSTRAINT IF EXISTS e_socios_inter_comer_tb_e_print_tb_fkey;

	ALTER TABLE docwin.e_socios_inter_comer_tb
	  ADD CONSTRAINT e_socios_inter_comer_tb_e_print_tb_fkey FOREIGN KEY (pr_key)
		  REFERENCES docwin.e_prin_tb (pr_key) MATCH SIMPLE
		  ON UPDATE NO ACTION ON DELETE CASCADE;
	
END;
$$ LANGUAGE plpgsql VOLATILE;
SELECT docwin.alteracoes_r011();
DROP FUNCTION IF EXISTS docwin.alteracoes_r011();



--0.12

UPDATE docwin.aux_preferencias_tb SET valor='0.12' WHERE nome='inf_bd_rel';

CREATE OR REPLACE FUNCTION docwin.alteracoes_r011() RETURNS void as
$$
BEGIN
	IF NOT EXISTS (SELECT column_name FROM information_schema.columns WHERE table_schema='docwin' AND table_name='e_prin_tb' AND column_name='pr_448' )
	THEN
		ALTER TABLE docwin.e_prin_tb ADD COLUMN pr_448 text;
		ALTER TABLE docwin.e_prin_tb ADD COLUMN pr_449 integer;

		INSERT INTO docwin.aux_func_tb VALUES (448, 'E', 'Folha de registo na unidade consular/serventia de t�tulos e documentos', 'Campo do banco de dados.', 0, 'T', 80, NULL, NULL, NULL);	
		INSERT INTO docwin.aux_func_tb VALUES (449, 'E', 'Termo de registo na unidade consular/serventia de t�tulos e documentos', 'Campo do banco de dados.', 0, 'N', NULL, NULL, NULL, NULL);	
   	
	END IF;	
		
END;
$$ LANGUAGE plpgsql VOLATILE;
SELECT docwin.alteracoes_r011();
DROP FUNCTION IF EXISTS docwin.alteracoes_r011();


-- 0.13

CREATE OR REPLACE FUNCTION docwin.alteracoes_r011() RETURNS void as
$$
BEGIN
	IF NOT EXISTS (SELECT column_name FROM information_schema.columns WHERE table_schema='docwin' 
									AND table_name='c_pcas_detalhes_tb' AND column_name='datautilizacao_selodigital_termo' )
	THEN
		ALTER TABLE docwin.c_pcas_detalhes_tb ADD COLUMN datautilizacao_selodigital_termo date;
	END IF;	
	
	IF NOT EXISTS (SELECT column_name FROM information_schema.columns WHERE table_schema='docwin' 
									AND table_name='c_pcas_detalhes_tb' AND column_name='selodigital_habilitacao' )
	THEN
		ALTER TABLE docwin.c_pcas_detalhes_tb ADD COLUMN selodigital_habilitacao text;
		ALTER TABLE docwin.c_pcas_detalhes_tb ADD COLUMN datautilizacao_selodigital_habilitacao date;
	END IF;	
	
	IF NOT EXISTS (SELECT column_name FROM information_schema.columns WHERE table_schema='docwin' 
									AND table_name='pessoa_fisica_tb' AND column_name='pf_cnh' )
	THEN
		ALTER TABLE docwin.pessoa_fisica_tb ADD COLUMN pf_cnh text;
		ALTER TABLE docwin.pessoa_fisica_tb ADD COLUMN pf_cnh_uf text;
		ALTER TABLE docwin.pessoa_fisica_tb ADD COLUMN pf_complemento_qualificacao_conjuge text;
		ALTER TABLE docwin.pessoa_fisica_tb ADD COLUMN pf_residencia_domicilio_mesmo_endereco boolean default true;
		ALTER TABLE docwin.pessoa_fisica_tb ADD COLUMN pf_logradouro_end_domicilio text;
		ALTER TABLE docwin.pessoa_fisica_tb ADD COLUMN pf_numero_end_domicilio text;
		ALTER TABLE docwin.pessoa_fisica_tb ADD COLUMN pf_complemento_end_domicilio text;
		ALTER TABLE docwin.pessoa_fisica_tb ADD COLUMN pf_bairro_end_domicilio text;
		ALTER TABLE docwin.pessoa_fisica_tb ADD COLUMN pf_cidade_end_domicilio text;
		ALTER TABLE docwin.pessoa_fisica_tb ADD COLUMN pf_uf_end_domicilio text;
		ALTER TABLE docwin.pessoa_fisica_tb ADD COLUMN pf_cep_end_domicilio text;
		ALTER TABLE docwin.pessoa_fisica_tb ADD COLUMN pf_pais_end_domicilio text;
		ALTER TABLE docwin.pessoa_fisica_historico_tb ADD COLUMN ph_cnh text;
		ALTER TABLE docwin.pessoa_fisica_historico_tb ADD COLUMN ph_cnh_uf text;
		ALTER TABLE docwin.pessoa_fisica_historico_tb ADD COLUMN ph_complemento_qualificacao_conjuge text;
		ALTER TABLE docwin.pessoa_fisica_historico_tb ADD COLUMN ph_residencia_domicilio_mesmo_endereco boolean default true;
		ALTER TABLE docwin.pessoa_fisica_historico_tb ADD COLUMN ph_logradouro_end_domicilio text;
		ALTER TABLE docwin.pessoa_fisica_historico_tb ADD COLUMN ph_numero_end_domicilio text;
		ALTER TABLE docwin.pessoa_fisica_historico_tb ADD COLUMN ph_complemento_end_domicilio text;
		ALTER TABLE docwin.pessoa_fisica_historico_tb ADD COLUMN ph_bairro_end_domicilio text;
		ALTER TABLE docwin.pessoa_fisica_historico_tb ADD COLUMN ph_cidade_end_domicilio text;
		ALTER TABLE docwin.pessoa_fisica_historico_tb ADD COLUMN ph_uf_end_domicilio text;
		ALTER TABLE docwin.pessoa_fisica_historico_tb ADD COLUMN ph_cep_end_domicilio text;
		ALTER TABLE docwin.pessoa_fisica_historico_tb ADD COLUMN ph_pais_end_domicilio text;
	END IF;

		
END;
$$ LANGUAGE plpgsql VOLATILE;
SELECT docwin.alteracoes_r011();
DROP FUNCTION IF EXISTS docwin.alteracoes_r011();



--Iverson

CREATE OR REPLACE FUNCTION docwin.alteracoes_r013() RETURNS void as
$$
BEGIN

	IF NOT EXISTS (SELECT column_name FROM information_schema.columns WHERE table_schema='docwin' AND table_name='u_ordem_servico_tb' AND column_name='cpf_cnpj_cliente' )
	THEN
		ALTER TABLE docwin.u_ordem_servico_tb ADD COLUMN cpf_cnpj_cliente text;			
			
		INSERT INTO docwin.aux_func_tb VALUES (20, 'U', 'N�mero do CPF/CNPJ', 'Campo do banco de dados. Neste campo � armazenado o n�mero do CPF ou CNPJ do cliente.', 0, 'T', 80, NULL, NULL, NULL);	
			
		PERFORM docwin.inserealterahelp('U','C','UCOSCPFCL','

   Neste campo voc� informa o 
   n�mero do CPF ou CNPJ.','CPF/CNPJ');
   	
	END IF;	
	IF NOT EXISTS (SELECT column_name FROM information_schema.columns WHERE table_schema='docwin' AND table_name='u_ordem_servico_tb' AND column_name='registrado' )
	THEN
		ALTER TABLE docwin.u_ordem_servico_tb ADD COLUMN registrado text;			
			
		INSERT INTO docwin.aux_func_tb VALUES (30, 'U', 'Nome do registrado', 'Campo do banco de dados. Neste campo � armazenado o nome do registrado no qual o servi�o ser� executado.', 0, 'T', 80, NULL, NULL, NULL);	
			
		PERFORM docwin.inserealterahelp('U','C','UCOS2PART','

   Neste campo voc� inclui o nome
   da pessoa no qual o servi�o ser�
   executado.','Nome do registrado');
   	
	END IF;	
	
	
	IF NOT EXISTS (SELECT column_name FROM information_schema.columns WHERE table_schema='docwin' AND table_name='u_ordem_servico_tb' AND column_name='cpf_cnpj_registrado' )
	THEN
		ALTER TABLE docwin.u_ordem_servico_tb ADD COLUMN cpf_cnpj_registrado text;			
			
		INSERT INTO docwin.aux_func_tb VALUES (31, 'U', 'N�mero do CPF/CNPJ do registrado', 'Campo do banco de dados. Neste campo � armazenado o n�mero do CPF ou CNPJ do registrado.', 0, 'T', 80, NULL, NULL, NULL);	
			
		PERFORM docwin.inserealterahelp('U','C','UCOSCPF2PART','

   Neste campo voc� informa o 
   n�mero do CPF ou CNPJ do
   registrado.','CPF/CNPJ');
   	
	END IF;	
	
	IF NOT EXISTS (SELECT column_name FROM information_schema.columns WHERE table_schema='docwin' AND table_name='n_pnas_tb' AND column_name='pn_319' )
	THEN
		ALTER TABLE docwin.n_pnas_tb ADD COLUMN pn_319 smallint DEFAULT 9;
	END IF;	
	
	IF NOT EXISTS (SELECT column_name FROM information_schema.columns WHERE table_schema='docwin' AND table_name='n_pnas_tb' AND column_name='pn_339' )
	THEN
		ALTER TABLE docwin.n_pnas_tb ADD COLUMN pn_339 smallint DEFAULT 9;
	END IF;	
		
END;
$$ LANGUAGE plpgsql VOLATILE;
SELECT docwin.alteracoes_r013();
DROP FUNCTION IF EXISTS docwin.alteracoes_r013();





--0.14

UPDATE docwin.aux_preferencias_tb SET valor='0.14' WHERE nome='inf_bd_rel';
--HELP
SELECT docwin.inserealterahelp('O','C','OC300','
     Digite aqui a UF do CRM
     do m�dico que atestou o
     �bito.','UF do primeiro m�dico');
SELECT docwin.inserealterahelp('O','C','OC110','
     Digite aqui a UF do CRM
     do m�dico que atestou o
     �bito.','UF do segundo m�dico');
SELECT docwin.inserealterahelp('N','C','NC250','

   Digite aqui a UF do CRM
   do m�dico.','Uf do m�dico');
SELECT docwin.inserealterahelp('O','C','OC350','	
 
    Digite aqui o n�mero do protocolo.','N� do protocolo');
SELECT docwin.inserealterahelp('O','C','OC111','	

    Informar o n� do processo que
    originou este registro.','N� do processo');

SELECT docwin.inserealterahelp('N','C','NC114',' 
   Digite o n�mero do rg do registrado 
   aqui.','RG do Registrado');
SELECT docwin.inserealterahelp('N','C','NC115','
 Digite o �rg�o emissor do RG aqui.','�rg�o Emissor');
SELECT docwin.inserealterahelp('N','C','NC116','
   Digite a data de emiss�o do RG aqui.','Data de Emiss�o');
SELECT docwin.inserealterahelp('N','C','NC313','	

  Escolha o tipo de documento 
  ','Tipo de Documento');
SELECT docwin.inserealterahelp('N','C','NC313','	

 Escolha o tipo de documento apresentado 
 pelo pai do/a registrado/a.
  ','Tipo de Documento');
SELECT docwin.inserealterahelp('N','C','NC312','


   Digite aqui o n�mero do documento 
   apresentado   pelo   pai     do/a 
   registrado/a.		','Documento');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.N.UI.frmInclui.groupBox6.pnlVarAdi2','','Campos Suposto Pai');
SELECT docwin.inserealterahelp('A','C','ACDeMaria.DOC.N.UI.frmInclui.groupBox6.pnlVarAdi2','

  Campos destinados ao registrado que 
  n�o  tem  informa��es   suficientes
  do pai. ','Campos Suposto Pai');


--Pedro
CREATE OR REPLACE FUNCTION docwin.criarPermissoes() RETURNS void as
$$
BEGIN

	IF NOT EXISTS (SELECT * FROM docwin.aux_tfun_tb WHERE tf_id = 453)
	THEN
		INSERT INTO docwin.aux_tfun_tb(tf_id, tf_prog, tf_nomfun, tf_sub, tf_perm)
		VALUES (453, 'U_RE_ATOA', 'Relat�rio de Atos Praticados (Ato Padronizado)', 420, '');
	END IF;
	
END;
$$ LANGUAGE plpgsql VOLATILE;
GRANT EXECUTE ON FUNCTION docwin.criarPermissoes() TO escreventes;
GRANT EXECUTE ON FUNCTION docwin.criarPermissoes() TO supervisores;
SELECT docwin.criarPermissoes();
DROP FUNCTION IF EXISTS docwin.criarPermissoes();




CREATE OR REPLACE RULE log_termo_exclui AS
    ON DELETE TO docwin.f_termos_comparecimento_tb DO  INSERT INTO docwin.aux_log_tb (log_user_login, log_datetime, log_oper, log_tab, log_info, log_user_ip)
  VALUES ("current_user"(), now(), 'Exclus�o de Termo de Comparecimento'::text, 
  'Firmas'::text, 
   ('Livro '::text || old.tc_livro::text) || (' Folha '::text)
 || (old.tc_folha::text) || (old.tc_verso::text) || (' Termo '::text) ||
  (old.tc_numero::text) || (', Firma n�mero '::text || old.tc_firma::text) || (' '::text) ||
   coalesce((SELECT  p.pf_nome FROM docwin.pessoa_fisica_tb as p 
 left join docwin.f_firma_tb as f on f.fi_pessoa = p.pf_id where f.fi_id = old.tc_firma)::text || ')'::text, ''), inet_client_addr());



CREATE OR REPLACE RULE log_termo_inclui AS
    ON INSERT TO docwin.f_termos_comparecimento_tb DO  INSERT INTO docwin.aux_log_tb
     (log_user_login, log_datetime, log_oper, log_tab, log_info, log_user_ip)
  VALUES ("current_user"(), now(), 'Inclus�o de Termo de Comparecimento'::text, 'Firmas'::text,
    ('Livro '::text || new.tc_livro::text) || (' Folha '::text)
 || (new.tc_folha::text) || (new.tc_verso::text) || (' Termo '::text) ||
  (new.tc_numero::text) || (', Firma n�mero '::text || new.tc_firma::text) || (' '::text) ||
   coalesce((SELECT  p.pf_nome FROM docwin.pessoa_fisica_tb as p 
 left join docwin.f_firma_tb as f on f.fi_pessoa = p.pf_id where f.fi_id = new.tc_firma)::text || ')'::text, ''), inet_client_addr());

		  
		  
		CREATE OR REPLACE RULE log_termo_altera AS
    ON UPDATE TO docwin.f_termos_comparecimento_tb DO INSERT INTO docwin.aux_log_tb
     (log_user_login, log_datetime, log_oper, log_tab, log_info, log_user_ip)
  VALUES ("current_user"(), now(), 'Altera��o de Termo de Comparecimento'::text, 'Firmas'::text,
   ('Livro '::text || old.tc_livro::text) || (' Folha '::text)
 || (old.tc_folha::text) || (old.tc_verso::text) || (' Termo '::text) ||
  (old.tc_numero::text) || (', Firma n�mero '::text || old.tc_firma::text) || (' '::text) ||
   coalesce((SELECT  p.pf_nome FROM docwin.pessoa_fisica_tb as p 
 left join docwin.f_firma_tb as f on f.fi_pessoa = p.pf_id where f.fi_id = old.tc_firma)::text || ')'::text, ''), inet_client_addr());  

 
 
  
 
CREATE OR REPLACE FUNCTION docwin.colunas() RETURNS void as
$$
BEGIN

		
	IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
                   WHERE table_schema='docwin' AND table_name='u_item_ordem_servico_tb' AND column_name='protocolo_id')
    THEN
		ALTER TABLE docwin.u_item_ordem_servico_tb ADD COLUMN protocolo_id int;
    END IF;
	
END;
$$ LANGUAGE plpgsql VOLATILE;
GRANT EXECUTE ON FUNCTION docwin.colunas() TO escreventes;
GRANT EXECUTE ON FUNCTION docwin.colunas() TO supervisores;
SELECT docwin.colunas();
DROP FUNCTION IF EXISTS docwin.colunas();

--Gustavo
CREATE OR REPLACE FUNCTION docwin.release014() RETURNS void as
$$
BEGIN

	IF NOT EXISTS (SELECT column_name FROM information_schema.columns WHERE table_schema='docwin' AND table_name='o_pobi_tb' AND column_name='po_111')
	THEN
		ALTER TABLE docwin.o_pobi_tb ADD COLUMN po_111 text;
		ALTER TABLE docwin.o_pobi_tb ADD COLUMN po_350 text;
		Update docwin.o_pobi_tb set po_350=po_300, po_111=po_111;
		
		INSERT INTO docwin.aux_func_tb VALUES (111, 'O', 'N� do processo', 'Campo do banco de dados. Caiu em desuso. Utilizava-se para estat�stica apenas nos cart�rios de SP..', 0, 'T', 80, NULL, NULL, NULL);	
		INSERT INTO docwin.aux_func_tb VALUES (350, 'O', 'N� do protocolo', 'Campo do banco de dados. Neste campo � armazenado o n�mero do protocolo.', 0, 'N', NULL, NULL, NULL, NULL);	
		
	END IF;
	
	IF EXISTS(SELECT * FROM docwin.aux_func_tb WHERE fu_cod=300 AND fu_mod='O')
	THEN
		UPDATE docwin.aux_func_tb SET 	fu_tit='UF do primeiro m�dico',
										fu_dsc='Campo do banco de dados. UF do CRM do primeiro m�dico.',
										fu_tipo='T',
										fu_tamanho=2,
										fu_mask='>LL'
		 WHERE fu_cod=300 AND fu_mod='O';
	ELSE
		INSERT INTO docwin.aux_func_tb VALUES (300, 'O', 'UF do primeiro m�dico', 'Campo do banco de dados. UF do CRM do primeiro m�dico.', 0, 'T', 2, '>LL', NULL, NULL);	
	END IF;
	
	IF EXISTS(SELECT * FROM docwin.aux_func_tb WHERE fu_cod=110 AND fu_mod='O')
	THEN
		UPDATE docwin.aux_func_tb SET 	fu_tit='UF do segundo m�dico',
										fu_dsc='Campo do banco de dados. UF do CRM do segundo m�dico.',
										fu_tipo='T',
										fu_tamanho=2,
										fu_mask='>LL'
		 WHERE fu_cod=110 AND fu_mod='O';
	ELSE
		INSERT INTO docwin.aux_func_tb VALUES (110, 'O', 'UF do segundo m�dico', 'Campo do banco de dados. UF do CRM do segundo m�dico.', 0, 'T', 2, '>LL', NULL, NULL);	
	END IF;
	
	IF NOT EXISTS (SELECT column_name FROM information_schema.columns WHERE table_schema='docwin' AND table_name='n_pnas_tb' AND column_name='pn_250')
	THEN
		ALTER TABLE docwin.n_pnas_tb ADD COLUMN pn_250 text;
	END IF;
	
	IF NOT EXISTS(SELECT * FROM docwin.aux_func_tb WHERE fu_cod=250 AND fu_mod='N') THEN
		INSERT INTO docwin.aux_func_tb VALUES (250, 'N', 'UF do m�dico', 'Campo do banco de dados. UF do CRM do m�dico.', 0, 'T', 2, '>LL', NULL, NULL);	
	END IF;
	
END;
$$ LANGUAGE plpgsql VOLATILE;
GRANT EXECUTE ON FUNCTION docwin.release014() TO escreventes;
GRANT EXECUTE ON FUNCTION docwin.release014() TO supervisores;
SELECT docwin.release014();
DROP FUNCTION IF EXISTS docwin.release014();


-- 0.15-Lojas

 --Wesley
CREATE OR REPLACE FUNCTION docwin.colunas() RETURNS void as
$$
BEGIN
		
	IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
                   WHERE table_schema='docwin' AND table_name='o_pobi_tb' AND column_name='po_488')
    THEN
		ALTER TABLE docwin.o_pobi_tb ADD COLUMN po_488 text;
    END IF;
	
	IF NOT EXISTS (SELECT * FROM docwin.aux_func_tb WHERE fu_cod = 488 and fu_mod = 'O')
    THEN
		INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) VALUES (488, 'O', 'Descri��o do �rg�o Emissor', 'Fun��o especial. Retorna o a descri��o do �rg�o emissor do falecido, quando o mesmo for da tipo "OUTROS"', 0, 'T', NULL, NULL, NULL, NULL);
	END IF;
	
END;
$$ LANGUAGE plpgsql VOLATILE;
GRANT EXECUTE ON FUNCTION docwin.colunas() TO escreventes;
GRANT EXECUTE ON FUNCTION docwin.colunas() TO supervisores;
SELECT docwin.colunas();
DROP FUNCTION IF EXISTS docwin.colunas();




 
 
CREATE OR REPLACE FUNCTION docwin.colunas() RETURNS void as
$$
BEGIN
		
	IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
                   WHERE table_schema='docwin' AND table_name='n_pnas_tb' AND column_name='pn_317')
    THEN
		ALTER TABLE docwin.n_pnas_tb ADD COLUMN pn_317 text;
    END IF;
	
	IF NOT EXISTS (SELECT * FROM docwin.aux_func_tb WHERE fu_cod = 317 and fu_mod = 'N')
    THEN
		INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) VALUES (317, 'N', 'Telefone do Pai', 'Retorna o n�mero de telefone do pai do registrado.',0, 'T', 13,'(99)999999999', NULL, NULL);
	END IF;
	
	
	IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
                   WHERE table_schema='docwin' AND table_name='n_pnas_tb' AND column_name='pn_337')
    THEN
		ALTER TABLE docwin.n_pnas_tb ADD COLUMN pn_337 text;
    END IF;
	
	IF NOT EXISTS (SELECT * FROM docwin.aux_func_tb WHERE fu_cod = 337 and fu_mod = 'N')
    THEN
		INSERT INTO docwin.aux_func_tb (fu_cod, fu_mod, fu_tit, fu_dsc, fu_lnk, fu_tipo, fu_tamanho, fu_mask, fu_cont, fu_altera) VALUES (337, 'N', 'Telefone da M�e', 'Retorna o n�mero de telefone da m�e do registrado.',0, 'T', 13, '(99)999999999', NULL, NULL);
	END IF;
	
	
	
	
END;
$$ LANGUAGE plpgsql VOLATILE;
GRANT EXECUTE ON FUNCTION docwin.colunas() TO escreventes;
GRANT EXECUTE ON FUNCTION docwin.colunas() TO supervisores;
SELECT docwin.colunas();
DROP FUNCTION IF EXISTS docwin.colunas();




--Pedro

CREATE OR REPLACE RULE log_transf_veiculo_altera AS
    ON UPDATE TO docwin.f_transf_veiculo_tb DO 
   INSERT INTO docwin.aux_log_tb (log_user_login, log_datetime, log_oper, log_tab, log_info, log_user_ip)
  VALUES ("current_user"(), now(), 'Altera��o de Transfer�ncia de ve�culo'::text, 'Firmas'::text,
   (('Placa '::text || old.placa::text) || (', Modelo '::text || old.modelo::text)
   || (' Renavam '::text || old.renavam::text) || 
  (', Data venda '::text ||  COALESCE(old.data_venda::text,''::text))
   || ' '::text), inet_client_addr());
 
CREATE OR REPLACE RULE log_transf_veiculo_exclui AS
    ON DELETE TO docwin.f_transf_veiculo_tb DO 
INSERT INTO docwin.aux_log_tb (log_user_login, log_datetime, log_oper, log_tab, log_info, log_user_ip)
  VALUES ("current_user"(), now(), 'Exclus�o de Transfer�ncia de ve�culo'::text, 'Firmas'::text,
   (('Placa '::text || old.placa::text) || (', Modelo '::text || old.modelo::text)
   || (' Renavam '::text || old.renavam::text) || 
  (', Data venda '::text ||  COALESCE(old.data_venda::text,''::text))
   || ' '::text), inet_client_addr());

 
CREATE OR REPLACE RULE log_transf_veiculo_inclui AS
    ON INSERT TO docwin.f_transf_veiculo_tb DO 
          INSERT INTO docwin.aux_log_tb (log_user_login, log_datetime, log_oper, log_tab, log_info, log_user_ip)
  VALUES ("current_user"(), now(), 'Inclus�o de Transfer�ncia de ve�culo'::text, 'Firmas'::text,
   (('Placa '::text || new.placa::text) || (', Modelo '::text || new.modelo::text)
   || (' Renavam '::text || new.renavam::text) || 
  (', Data venda '::text ||  COALESCE(new.data_venda::text,''::text))
   || ' '::text), inet_client_addr());


   
CREATE OR REPLACE FUNCTION docwin.criarPermissoes() RETURNS void as
$$
BEGIN
 
 IF NOT EXISTS (SELECT * FROM docwin.aux_tfun_tb WHERE tf_id = 407)
	THEN
	INSERT INTO docwin.aux_tfun_tb(tf_id, tf_prog, tf_nomfun, tf_sub, tf_perm)
	VALUES (407, 'U_REAB_OS', 'Reabrir ordens de servi�os finalizadas', 400, '');
END IF; 
 
END;
$$ LANGUAGE plpgsql VOLATILE;
GRANT EXECUTE ON FUNCTION docwin.criarPermissoes() TO escreventes;
GRANT EXECUTE ON FUNCTION docwin.criarPermissoes() TO supervisores;
SELECT docwin.criarPermissoes();
DROP FUNCTION IF EXISTS docwin.criarPermissoes();

 
 
UPDATE docwin.aux_preferencias_tb SET valor='0.15' WHERE nome='inf_bd_rel';
UPDATE docwin.aux_preferencias_tb SET valor='2017' WHERE nome='inf_bd_ver';
 
 --Atualizado at� a vers�o 0.15   
