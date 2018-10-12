CREATE OR REPLACE PACKAGE PG_TABLA_EXTERNA IS 

        PROCEDURE PA_CREAR_TABLA_EXTERNA 
                          (P_NOMBRE_ARCHIVO VARCHAR2);
        PROCEDURE PA_BORRAR_TABLA_EXTERNA;                  

END  PG_TABLA_EXTERNA;

CREATE OR REPLACE PACKAGE BODY PG_TABLA_EXTERNA
IS

            PROCEDURE PA_CREAR_TABLA_EXTERNA
                             (P_NOMBRE_ARCHIVO VARCHAR2) IS

                    V_SLQ_CADENA VARCHAR(500):=' ';

                    BEGIN

                    V_SLQ_CADENA := ' CREATE TABLE SEOWEB.UNIVERSOS_DBF_TEMP(FAMILIA_ID NUMBER(9), ESTADO_ID NUMBER(2)) 
                    organization external
                    (
                    default directory  UNIVERSOS
                    access parameters
                      (
                      records delimited by newline
                      fields terminated by ''|''
                      )
                      location ('|| chr(39)||P_NOMBRE_ARCHIVO||chr(39) ||'))';

                   DBMS_OUTPUT.PUT_LINE(V_SLQ_CADENA);
                    EXECUTE IMMEDIATE V_SLQ_CADENA;
                      EXCEPTION
                         WHEN OTHERS THEN
                           DBMS_OUTPUT.PUT_LINE( DBMS_UTILITY.FORMAT_ERROR_STACK );
                          RAISE;
            END PA_CREAR_TABLA_EXTERNA;
            
            PROCEDURE PA_BORRAR_TABLA_EXTERNA IS

            V_CONT NUMBER := 0;

            BEGIN               
                    SELECT COUNT(1) INTO V_CONT FROM USER_TABLES WHERE UPPER(TABLE_NAME) = 'SEOWEB.UNIVERSOS_DBF_TEMP';     
                    
                    IF V_CONT > 0 THEN                    
                        EXECUTE  IMMEDIATE 'DROP TABLE SEOWEB.UNIVERSOS_DBF_TEMP CASCADE CONSTRAINTS';                    
                    END IF;                                                             
                   EXCEPTION                    
                     WHEN OTHERS THEN
                       RAISE_APPLICATION_ERROR 
                         (-20001, 'Ha ocurrido un error al intentar borrar la tabla externa.');
                                  
                END PA_BORRAR_TABLA_EXTERNA;

END  PG_TABLA_EXTERNA;