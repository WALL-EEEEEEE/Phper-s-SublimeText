open Common

open Oassoc

(* !!take care!!: this class does side effect, it's not a pure oassoc!
 *
 * Why using a gdbm-like data store? Why not use the filesystem
 * and represent the "foo"->"data" key/value as a file /mystore/foo
 * containing "data"? This is what git does for instance with
 * its .git/objects/ directory.
 * 
 *  - looking up a key in a directory can be slow on certain filesystems.
 *    This is less true with modern fs which use btrees to represent
 *    directories. Moreover you can use the same trick than
 *    git by having intermediate directories
 *  - you are limited to 256 characters for the key (the maximal length
 *    of a file)
 *  - if your value is small, you can lose lots of space. But again
 *    this is less true on certain fs which use "extents"
 *  - gdbm is really simple, if you just need a persistent hashtbl,
 *    it's pretty simple to use. Using a filesystem will force
 *    you to implement yourself the lookup/add/get/etc.
 *  - gdbm is probably faster than using a fs
 *  - you can have transactions with certain gdbm-like store
 *    (e.g. berkeley DB)
 * 
 * The fv/unv are here to give the opportunity to translate the value
 * from the dbm, before marshalling. This is useful for instance if you
 * want to store objects such as oset. Indeed we cant marshall
 * conveniently functions/closures, and so objects (you can but you can
 * load them back only from the same binary, which limits the
 * practicallibity of the approach). You have to translate them to
 * traditionnal data structures before marshalling them, and you have
 * to rebuild the object from the traditionnal data structure when you
 * get them from the dbm. Hence fv/unv. You can do the same for the key
 * with fkey/unkey, but as key are usually simple data structures,
 * there is less need for them, so I have commented them. 
 *)
class ['a,'b] oassocdbm   xs db (*fkey unkey*) fv unv = 
object(o)
  inherit ['a,'b] oassoc
    
  val db = db
    
  method empty = raise Todo
  method add (k,v) = 
    (* pr2 (fkey k); *)
    (* pr2 (debugv v); *)

    (* try Db.del data None 
       (Marshal.to_string k []) [] 
       with Not_found -> ());
    *)
    let k' = Common.marshal__to_string k [] in
    let v' = (Common.marshal__to_string (fv v) [(*Common.marshal__Closures*)]) in
    (try Dbm.add db k' v' 
      with _ -> Dbm.replace db k' v'
    );
    o

  method iter f = 
    db +> Dbm.iter (fun key data -> 
      let k' = (* unkey *) Common.marshal__from_string key 0 in 
      let v' = unv (Common.marshal__from_string data 0) in
      f (k', v')
    ) 
     
  method view = raise Todo
    
  method del (k,v) = raise Todo
  method mem e = raise Todo
  method null = raise Todo
    
  method assoc k = 
    let k' = Common.marshal__to_string k [] in
    unv (Common.marshal__from_string (Dbm.find db k') 0)

  method delkey k = 
    let k' = Common.marshal__to_string k [] in
    try 
      Dbm.remove db k';
      o
    with Dbm.Dbm_error "dbm_delete" -> 
      raise Not_found

  method keys = 
    let res = ref [] in 
    db +> Dbm.iter (fun key data -> 
      let k' = (* unkey *) Common.marshal__from_string key 0 in 
      (* 
         let v' = unv (Common.marshal__from_string data 0) in
         f (k', v')
      *)
      Common.push k' res;
    );
    !res

end


let create_dbm metapath dbname =
  let x_db = Dbm.opendbm (metapath^dbname) [Dbm.Dbm_create;Dbm.Dbm_rdwr] 0o777 
  in
  let assoc = new oassocdbm [] x_db id id in
  x_db, assoc

