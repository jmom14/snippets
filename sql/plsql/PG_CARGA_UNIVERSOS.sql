CREATE OR REPLACE PACKAGE PG_CARGA_UNIVERSOS
IS
	PROCEDURE PA_INSERTAR_LOG(
			v_FAMILIA_ID NUMBER,
			v_ESTADO_ID NUMBER,
			v_REMESA_PROCESO_ID NUMBER,
			v_OBSERVACIONES VARCHAR2,
			v_TIPO_CARGA NUMBER 
			);
	FUNCTION GET_CURSOR(
			v_REMESA_CUDM NUMBER
			)RETURN SYS_REFCURSOR;
	PROCEDURE PA_INSERTAR_FAMILIA_UNIVERSO(
		   v_REMESA_PROCESO_ID NUMBER, 
		   v_ESTADO_ID NUMBER, 
		   v_FAMILIA_ID NUMBER,
		   v_PROCESO_ID NUMBER
			);
	PROCEDURE PA_INSERTAR_DOMICILIO(
			v_FAMILIA_ID NUMBER,
			v_ESTADO_ID NUMBER,
			v_REMESA_PROCESO_ID NUMBER
			 );
    PROCEDURE PA_ACT_FAMILIAS_DOM;
    PROCEDURE PA_CARGAR_FAMILIAS_CRIS(
            v_REMESA_CUDM NUMBER,
            v_PROCESO NUMBER,
            v_DESCRIPCION_REMESA VARCHAR2,
            v_PERIODO_INICIO DATE,
			v_PERIODO_FIN DATE,
			v_VIGENCIA_ATENCION DATE,
			v_VIGENCIA_CAPTURA DATE,
            v_BIMESTRE NUMBER,
            v_REMESA_NUEVA NUMBER,
            v_REMESA_EXISTENTE NUMBER,   
            v_USUARIO VARCHAR2);

			
END PG_CARGA_UNIVERSOS;

CREATE OR REPLACE PACKAGE BODY PG_CARGA_UNIVERSOS
IS

	PROCEDURE PA_INSERTAR_LOG(
		v_FAMILIA_ID NUMBER,
		v_ESTADO_ID NUMBER,
		v_REMESA_PROCESO_ID NUMBER,
		v_OBSERVACIONES VARCHAR2,
		v_TIPO_CARGA NUMBER 
		) IS

		BEGIN 

		INSERT INTO LOG_CARGA_FAMILIA (familia_id, estado_id, remesa_proceso_id, observaciones, fecha_actualizacion, tipo_carga)
		VALUES (v_FAMILIA_ID, v_ESTADO_ID ,v_REMESA_PROCESO_ID ,v_OBSERVACIONES, SYSDATE, v_TIPO_CARGA);

			EXCEPTION
						WHEN OTHERS
								THEN ROLLBACK;
										 raise_application_ERROR(-20001,sqlcode||' '||sqlerrm);       
		END PA_INSERTAR_LOG;
		
	FUNCTION GET_CURSOR(v_REMESA_CUDM NUMBER)
	RETURN SYS_REFCURSOR
	IS
		FAMILIAS SYS_REFCURSOR;
	BEGIN

		OPEN FAMILIAS FOR 
		SELECT FAMILIA_ID, ESTADO_ID FROM CUDM.CUDM_DETALLE_REMESA C  WHERE C.ID_REMESA = v_REMESA_CUDM;
		RETURN FAMILIAS;
		
	END GET_CURSOR;
	
	PROCEDURE PA_INSERTAR_FAMILIA_UNIVERSO(
	   v_REMESA_PROCESO_ID NUMBER, 
	   v_ESTADO_ID NUMBER, 
	   v_FAMILIA_ID NUMBER,
	   v_PROCESO_ID NUMBER
	   )IS

		BEGIN 

			 --1.-SE REALIZA LA INSERCION EN LA TABLA DE FAMILIA_REMESA_PROCESO
			 INSERT INTO FAMILIA_REMESA_PROCESO
			 SELECT v_REMESA_PROCESO_ID AS REMESA_PROCESO_ID, ESTADO_ID, FAMILIA_ID, ZONA_OPERACION_ID AS ZO_OPERACION_ID, SYSDATE AS FECHA_REGISTRO, 
			 (SELECT MAX(DOMICILIO_FAMILIA_ID) FROM DOMICILIO_FAMILIA_ANT1 WHERE FAMILIA_ID =  v_FAMILIA_ID AND ESTADO_ID = v_ESTADO_ID) AS DOMICILIO_FAMILIA_ID
			 FROM VM_SIIOP.FAMILIA F WHERE F.FAMILIA_ID =  v_FAMILIA_ID;													
			
			--2.-SE REALIZA LA INSERCION EN LA TABLA CFR_UNIVERSOS PARA POSTERIORMENTE REALIZAR LA GENERACION DE FOLIOS_FORMATOS 
			 INSERT INTO CFR_CARGA_UNIVERSOS (familia_id, id_proceso, fecha_carga, tipo_carga) VALUES (v_FAMILIA_ID, v_PROCESO_ID, SYSDATE , 2);
			 
			EXCEPTION
						WHEN OTHERS
								THEN ROLLBACK;
										 raise_application_ERROR(-20001,sqlcode||' '||sqlerrm);       
	   
	   END PA_INSERTAR_FAMILIA_UNIVERSO;	
	   
	PROCEDURE PA_INSERTAR_DOMICILIO(
    v_FAMILIA_ID NUMBER,
    v_ESTADO_ID NUMBER,
    v_REMESA_PROCESO_ID NUMBER
     ) IS    
    --VARIABLES QUE SE UTILIZAN PARA REALIZAR LAS VALIDACIONES
    v_EXISTE_DOMICILIO                  NUMBER(2);
    v_EXISTE_DOMICILIO_ANT          NUMBER(2);

	BEGIN
    
               SELECT COUNT(FAMILIA_ID) INTO v_EXISTE_DOMICILIO FROM VM_SIIOP.DOMICILIO_FAMILIA WHERE FAMILIA_ID = v_FAMILIA_ID AND ESTADO_ID = v_ESTADO_ID;
               --SI EXISTE EL DOMICILIO SE ENCUENTRA EN VM_SIIOP.DOMICILIO_FAMILIA, SE REALIZA LA CARGA DE SU DOMICILIO                                          
                IF v_EXISTE_DOMICILIO = 1  THEN
                                                                                                
                        --SE  REALIZA CARGA DE DOMICILIO A LA FAMILIA DE VM_SIIOP.DOMICILIO_FAMILIA                                           
                        INSERT INTO DOMICILIO_FAMILIA_ANT1
                        SELECT FAMILIA_ID, '' AS CALLE, NUMERO_EXTERIOR AS NUM_EXTERIOR, NUMERO_INTERIOR AS NUM_INTERIOR ,'' AS COLONIA,CODIGO_POSTAL,REFERENCIAS_UBICACION AS REFERENCIA, ESTADO_ID, TELEFONO,'' AS COLONIA_ID, ATENCION_OPERATIVA_ID, SISTEMA_COORDENADAS_ID, COORDENADA_GEOGRAFICA_1,
                        COORDENADA_GEOGRAFICA_2, COORDENADA_GEOGRAFICA_3, MANZANA_ID, '' AS CODIGO_POSTAL_ID, SQ_DOMFAMANT1_DOMFAMID.NEXTVAL AS DOMICILIO_FAMILIA_ID
						FROM VM_SIIOP.DOMICILIO_FAMILIA
                        WHERE FAMILIA_ID =  v_FAMILIA_ID 
                        AND ESTADO_ID = v_ESTADO_ID;   
                                                                                               
                ELSE                                                 
                                                     
                           --SI NO ENCONTRO EL DOMICILIO EN LA VISTA VM_SIIOP.DOMICILIO_FAMILIA, SE BUSCA EN EL LA VISTA DE VM_SIIOP.DOMICILIO_FAMILIA_ANT
                           SELECT COUNT(FAMILIA_ID) INTO v_EXISTE_DOMICILIO_ANT FROM VM_SIIOP.DOMICILIO_FAMILIA_ANT WHERE FAMILIA_ID =v_FAMILIA_ID AND ESTADO_ID = v_ESTADO_ID;                                                 
                                                                
                            IF  v_EXISTE_DOMICILIO_ANT = 1 THEN                                
                                                                    
                                     --SE  REALIZA CARGA DE DOMICILIO A LA FAMILIA DE VM_SIIOP.DOMICILIO_FAMILIA_ANT     
                                    INSERT INTO DOMICILIO_FAMILIA_ANT1
                                    SELECT FAMILIA_ID, CALLE, NUM_EXTERIOR,NUM_INTERIOR ,COLONIA,CODIGO_POSTAL,REFERENCIA, ESTADO_ID, TELEFONO,COLONIA_ID, ATENCION_OPERATIVA_ID, SISTEMA_COORDENADAS_ID, COORDENADA_GEOGRAFICA_1,
                                    COORDENADA_GEOGRAFICA_2, COORDENADA_GEOGRAFICA_3, MANZANA_ID, CODIGO_POSTAL_ID, SQ_DOMFAMANT1_DOMFAMID.NEXTVAL AS DOMICILIO_FAMILIA_ID
                                    FROM VM_SIIOP.DOMICILIO_FAMILIA_ANT
                                    WHERE FAMILIA_ID = v_FAMILIA_ID 
                                    AND ESTADO_ID = v_ESTADO_ID;                                                                        
                                         
                                                                            
                            ELSE                                                                                                               
                                    -- SI NO SE ENCUENTRA EL DOMICILIO, SE GUARDA INFORMACION EN LA TABVLA LOG_CARGA_FAMILIA    
                                      PA_INSERTAR_LOG(v_FAMILIA_ID, v_ESTADO_ID, v_REMESA_PROCESO_ID,'NO SE ENCONTRARON DATOS DE DOMICILIO PARA LA FAMILIA',2);    
                            END IF; 
                                
                END IF; 
                 
                                                    
    END PA_INSERTAR_DOMICILIO;
    

PROCEDURE PA_ACT_FAMILIAS_DOM
IS
           -- VARIABLES EN LAS CUALES SE ALMACENARAN LOS DATOS DEL CURSOR
            v_FAMILIA_ID                                NUMBER(9,0);
            v_ESTADO_C_ID                           NUMBER(2,0);
            v_ESTADO_ID                           NUMBER(2,0);
            v_REMESA_ID                           NUMBER(3,0);       
            v_PROCESO_ID                         NUMBER(2,0);
            v_REMESA_PROCESO_ID           NUMBER(2,0);
            --VARIABLES PARA VALIDACIONES       
            v_TIPO_CARGA                          NUMBER(2,0);
            
     CURSOR C_LIST_FAM_CAMBIO_DOM 
     IS
            --QUERY QUE OBTIENE LAS FAMILIAS QUE CAMBIARON DE DOMICILIO
            -- SOLO SE OBTIENEN LAS FAMILIAS DE  REMESAS VIGENTES      
            SELECT UNI.FAMILIA_ID, UNI.ESTADO_ID AS ESTADO_CARGA, FAM.ESTADO_ID AS ESTADO_ACTUAL,  RP.REMESA_ID, RP.PROCESO_ID, RP.REMESA_PROCESO_ID
            FROM 
            FAMILIA_REMESA_PROCESO UNI, VM_SIIOP.FAMILIA FAM,  REMESA_PROCESO RP
            WHERE 
            UNI.FAMILIA_ID = FAM.FAMILIA_ID
            AND UNI.REMESA_PROCESO_ID = RP.REMESA_PROCESO_ID
            AND UNI.ESTADO_ID <> FAM.ESTADO_ID
            AND FAM.FAMILIA_ID NOT IN(SELECT FAMILIA_ID FROM FAMILIA_REMESA_PROCESO WHERE FAMILIA_ID = FAM.FAMILIA_ID AND ESTADO_ID = FAM.ESTADO_ID)
            AND RP.VIGENTE = 1;

         BEGIN
                   -- SE ACTUALIZA EL PARAMETRO DE VALOR FECHA (LA CUAL SE TOMA COMO ULTIMA FECHA DE ACTUALIZACION PARA VALIDACION DE JOB)
                    UPDATE SEOWEB.CAT_PARAMETROS_SEOWEB
                         SET VALOR_FECHA = SYSDATE  WHERE PARAMETRO_ID = 10;
                    BEGIN
                                -- SE ABRE LISTADO DE FAMILIAS OBTENIDAS EN CURSOR
                                OPEN C_LIST_FAM_CAMBIO_DOM;
                                LOOP
                                      FETCH C_LIST_FAM_CAMBIO_DOM
                                      --SE ALMACENAN LOS VALORES DE C_LISTADO_FAMILIAS_CAMBIO_DOM
                                      INTO
                                        v_FAMILIA_ID,
                                        v_ESTADO_C_ID,
                                        v_ESTADO_ID,
                                        v_REMESA_ID,     
                                        v_PROCESO_ID,
                                        v_REMESA_PROCESO_ID;
                                        --SE TERMINA LA ITERACION CUANDO NO EXISTEN MAS DATOS EN EL CURSOR
                                        EXIT WHEN C_LIST_FAM_CAMBIO_DOM%NOTFOUND;
                                        v_TIPO_CARGA := 2;
                                        
                                         --PASO 1: CARGA DE DOMICLIO (SE INVOCA PROCEDIMIENTO PARA BUSQUEDA E INSERCIÓN DE DOMICILIO)
                                         PA_INSERTAR_DOMICILIO( v_FAMILIA_ID, v_ESTADO_ID,v_REMESA_PROCESO_ID);
                                         
                                         --PASOS  2, 3(NO APLICA EN ESTE CASO) Y 4
                                         PA_INSERTAR_FAMILIA_UNIVERSO( v_REMESA_PROCESO_ID, v_ESTADO_ID ,  v_FAMILIA_ID , v_PROCESO_ID);  
                                                      
                                         --5.-INVOCAMOS EL PROCEDIMIENTO PARA GENERAR LOS FOLIOS FORMATOS DE LAS FAMILIAS
                                         PA_GENERAR_FOLIOS_2345(v_PROCESO_ID, v_REMESA_ID, SYSDATE, v_FAMILIA_ID);
                                                             
                                         --6.- SE INSERTA EL DETALLE DE CAMBIO DE DOMICILIO
                                         INSERT INTO DET_CAMBIO_DOM_CRIS(familia_id, estado_carga_id, estado_actual_id, remesa_proceso_id, fecha_actualizacion, cambio_domicilio_id)
                                         VALUES(v_FAMILIA_ID, v_ESTADO_C_ID, v_ESTADO_ID, v_REMESA_PROCESO_ID, SYSDATE, SQ_CMBDOM_BITCMBDOMID.NEXTVAL);    
                                     
                                END LOOP; 
                                
                                CLOSE C_LIST_FAM_CAMBIO_DOM;
                                
                            COMMIT;
                            
                    EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                -- ERROR SI EL CURSOR NO DEVUELVE REGISTROS
                                Raise_application_error(-01403, 'El cursor no pudo obtener registros');
                            WHEN  OTHERS  THEN
                              raise_application_error(-20001,'Ocurrio un error en la ejecucion del procedimiento '||SQLCODE||' -ERROR- '||SQLERRM);
                              --SE REGISTRA OTRO TIPO DE ERROR
                            PA_INSERTAR_LOG( v_FAMILIA_ID, v_ESTADO_ID, v_REMESA_PROCESO_ID,'OCURRIO UN ERROR AL EJECUTARSE EL PROCEDIMIENTO',2);
                     END;
         -- TERMINA PROCEDIMIENTO
         END PA_ACT_FAMILIAS_DOM;
		 
       
    PROCEDURE PA_CARGAR_FAMILIAS_CRIS(
            v_REMESA_CUDM NUMBER,
            v_PROCESO NUMBER,
            v_DESCRIPCION_REMESA VARCHAR2,
            v_PERIODO_INICIO DATE,
			v_PERIODO_FIN DATE,
			v_VIGENCIA_ATENCION DATE,
			v_VIGENCIA_CAPTURA DATE,
            v_BIMESTRE NUMBER,
            v_REMESA_NUEVA NUMBER,
            v_REMESA_EXISTENTE NUMBER,   
            v_USUARIO VARCHAR2
            )IS             
			v_ROWS NUMBER(9):= 0;
			v_REMESA_PROCESO_ID NUMBER(9);                              
			v_REMESA_ID NUMBER (9);             
			v_CONTADOR NUMBER(9) := 0;       
			v_EXISTE_REMESA_VIGENTE NUMBER(2);   
			v_LOCAL_CURSOR SYS_REFCURSOR; 
			
			--VARIABLES QUE SE OCUPAN EN EL CURSOR
			v_FAMILIA_ID NUMBER(9);
			v_ESTADO_ID NUMBER (2);
			    
    
    BEGIN
        
        --SI EL TIPO DE CARGA ES 0 ES POR UNIVERSO, SI EL TIPO DE CARGA ES 1 ES POR DBF
       -- IF  v_TIPO_CARGA = 1 THEN                
       -- ELSE                
       -- END IF;
        
        --SI LA REMESA NUEVA ES 0 ES EXISTENTE, SI LA REMESA NUEVA ES 1 SE CREA UNA NUEVA
          IF    v_REMESA_NUEVA = 1 THEN 
          
                    SELECT MAX(REMESA_ID) INTO v_REMESA_ID FROM REMESA_PROCESO WHERE PROCESO_ID = v_PROCESO;                
                                             
                    INSERT INTO REMESA_PROCESO (REMESA_PROCESO_ID, REMESA_ID, VIGENTE, BIMESTRE_ID, DESCRIPCION, PROCESO_ID, FECHA_REGISTRO, REMESA_UNIVERSO_ID, TOTAL_FAMILIAS, ESTATUS_CARGA_ID,
                    TIPO_CARGA_ID, PERIODO_INICIO, PERIODO_FIN, VIGENCIA_ATENCION, VIGENCIA_CAPTURA)
                    VALUES (SQ_REMPROC_REMPROCID.NEXTVAL, v_REMESA_ID + 1, 1, v_BIMESTRE , v_DESCRIPCION_REMESA,v_PROCESO, SYSDATE, v_REMESA_CUDM, 0 ,1, 1,v_PERIODO_INICIO,
					v_PERIODO_FIN,v_VIGENCIA_ATENCION,v_VIGENCIA_CAPTURA);
                    
                    SELECT  SQ_REMPROC_REMPROCID.CURRVAL INTO v_REMESA_PROCESO_ID FROM DUAL;
                    
                    --INSERTA EN EL OBJETO MOVIMIENTO_REMESA LA CREACION DE UNA NUEVA REMESA
                    --MOVIMIENTO_REMESA_ID, REMESA_PROCESO_ID, PERSONAL_ID, TIPO_MOVIMIENTO_REMESA_ID, FECHA_REGISTRO
                    INSERT INTO MOVIMIENTO_REMESA VALUES (SQ_MOVREM_MOVREMID.NEXTVAL, v_REMESA_PROCESO_ID ,v_USUARIO,1,SYSDATE);
                    
        ELSE          
    
                    SELECT REMESA_PROCESO_ID INTO v_REMESA_PROCESO_ID FROM REMESA_PROCESO WHERE REMESA_ID = v_REMESA_EXISTENTE AND PROCESO_ID = v_PROCESO;
                    
                   --INSERTA EN EL OBJETO MOVIMIENTO_REMESA LA EDICION DE UNA REMESA REMESA EXISTENTE 
                   INSERT INTO MOVIMIENTO_REMESA VALUES (SQ_MOVREM_MOVREMID.NEXTVAL, v_REMESA_PROCESO_ID ,v_USUARIO, 4, SYSDATE);
                   
                   --SE INDICA QUE LA CARGA ESTARA EN PROCESO
                    UPDATE REMESA_PROCESO SET ESTATUS_CARGA_ID = 1 WHERE REMESA_PROCESO_ID =  v_REMESA_PROCESO_ID;
        
        END IF;
        
		v_LOCAL_CURSOR := GET_CURSOR(v_REMESA_CUDM);
				
			LOOP 
					FETCH v_LOCAL_CURSOR INTO v_FAMILIA_ID, v_ESTADO_ID;
					EXIT WHEN v_LOCAL_CURSOR%NOTFOUND;
                
        
                        --CONSULTA SI LA FAMILIA EXISTE EN UNA REMESA VIGENTE 
                        SELECT COUNT(*) INTO v_EXISTE_REMESA_VIGENTE FROM FAMILIA_REMESA_PROCESO FRP INNER JOIN REMESA_PROCESO RP ON FRP.REMESA_PROCESO_ID = RP.REMESA_PROCESO_ID
                        AND RP.VIGENTE = 1
                        AND FRP.FAMILIA_ID =v_FAMILIA_ID;
                        
                        -- SI NO ESTA CARGADO EN UNA REMESA VIGENTE ES IGUAL A 0 Y SIGUE CON EL PROCEDIMIENTO 
                        IF v_EXISTE_REMESA_VIGENTE = 0 THEN 
                                    
                                    --SE INSERTAN LOS DOMICILIOS PASANDO LOS SIGUIENTES PARAMETROS 
                                    -- v_FAMILIA_ID, v_ESTADO_ID,  v_REMESA_PROCESO_ID, v_TIENE_DOMICILIO 
                                    PA_INSERTAR_DOMICILIO(v_FAMILIA_ID, v_ESTADO_ID, v_REMESA_PROCESO_ID);
                        
                                    INSERT INTO  DET_ATENCION_REMESA_FAMILIA 
                                    SELECT v_REMESA_PROCESO_ID AS REMESA_PROCESO_ID, FAMILIA_ID, v_BIMESTRE AS BIMESTRE_ID, v_PERIODO_INICIO || ' - ' ||v_PERIODO_FIN AS PERIODO_ATENCION,
                                    V_VIGENCIA_ATENCION AS VIGENCIA_ATENCION, V_VIGENCIA_CAPTURA AS VIGENCIA_CAPTURA
                                    FROM VM_SIIOP.FAMILIA
                                    WHERE FAMILIA_ID = v_FAMILIA_ID; 

									v_ROWS := v_ROWS + sql%rowcount;
                                    
                                     --v_REMESA_PROCESO_ID, v_ESTADO_ID,v_FAMILIA_ID,v_PROCESO_ID
                                    PA_INSERTAR_FAMILIA_UNIVERSO(v_REMESA_PROCESO_ID, v_ESTADO_ID, v_FAMILIA_ID,  v_PROCESO);                                                                                   
                                    
                                    --SE GENERA EL FOLIO_FORMATO DE CADA FAMILIA
                                    PA_GENERAR_FOLIOS_2345(v_PROCESO, v_REMESA_ID + 1, SYSDATE, v_FAMILIA_ID);
                                     
                                    v_CONTADOR := v_CONTADOR  +1;                                                             
                                    IF v_CONTADOR = 1000 THEN                                                                
										 v_CONTADOR := 0;                                                   
										 COMMIT;                                                                            
                                    END IF;
                                                                
                        ELSE                        
                                --v_FAMILIA_ID,  v_ESTADO_ID, v_REMESA_PROCESO_ID, v_OBSERVACIONES, v_TIPO_CARGA = 1 PORQUE LO INSERTA A TRAVES DE ESTE PROCEDIMIENTO
                                PA_INSERTAR_LOG(v_FAMILIA_ID, v_ESTADO_ID, v_REMESA_PROCESO_ID, 'LA FAMILIA ESTA CARGADA EN UNA REMESA VIGENTE', 1);
                                
                        END IF;
            
            END LOOP;
            
            UPDATE REMESA_PROCESO SET ESTATUS_CARGA_ID = 2 WHERE REMESA_PROCESO_ID = v_REMESA_PROCESO_ID;
			
			IF v_REMESA_NUEVA = 1 THEN 					
            UPDATE REMESA_PROCESO SET TOTAL_FAMILIAS = v_ROWS WHERE REMESA_PROCESO_ID = v_REMESA_PROCESO_ID;    
			END IF;			
			
            COMMIT;
                      
                     EXCEPTION
                        WHEN OTHERS
                            THEN ROLLBACK;
                            
             --SE INDICA QUE LA CARHA HA FINALIZADO               
             UPDATE REMESA_PROCESO SET ESTATUS_CARGA_ID = 3 WHERE REMESA_PROCESO_ID = v_REMESA_PROCESO_ID;                                        
             raise_application_ERROR(-20001,sqlcode||' '||sqlerrm); 
   
   END PA_CARGAR_FAMILIAS_CRIS;
		 


--TERMINA PAQUETE
END PG_CARGA_UNIVERSOS;


