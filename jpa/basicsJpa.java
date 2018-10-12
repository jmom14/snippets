//insertar
Entidad ent  = new Enntidad(1, 'paramatro');

try{

em.getTransaction().begin();
em.persist(ent);
em.getTransaction().commit();

}catch(Exception e){
System.out.println(e);
}

//eliminar
Entidad entidad = em.find(Entidad.class, entidadId);
em.remove(entidad);
