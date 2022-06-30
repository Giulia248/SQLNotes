//
//  DB_Manager.swift
//  MySqliteCrudAppSwiftUI
//
//  Created by user on 27/06/22.
//

import Foundation
import SQLite


class DB_Manager {
     
    // sqlite instance
    private var db: Connection!
     
    // table instance
    private var users: Table!
 
    // columns instances of table
    private var id: Expression<Int64>!
    private var title: Expression<String>!
    private var noteText: Expression<String>!
 
     
    // constructor of this class
    init () {
         
        // exception handling
        do {
             
            // path of document directory
            let path: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
 
            // creating database connection
            db = try Connection("\(path)/my_users.sqlite3")
             
            // creating table object
            users = Table("users")
             
            // create instances of each column
            id = Expression<Int64>("id")
            title = Expression<String>("title")
            noteText = Expression<String>("noteText")
           
             
            // check if the user's table is already created
            if (!UserDefaults.standard.bool(forKey: "is_db_created")) {
 
                // if not, then create the table
                try db.run(users.create { (t) in
                    t.column(id, primaryKey: true)
                    t.column(title, unique: true)
                    t.column(noteText)
                })
                 
                // set the value to true, so it will not attempt to create the table again
                UserDefaults.standard.set(true, forKey: "is_db_created")
            }
             
        } catch {
            // show error message if any
            print(error.localizedDescription)
        }
         
    }
    
    public func addNote(titleValue: String, noteTextValue: String) {
        do {
            try db.run(users.insert(title <- titleValue, noteText <- noteTextValue))
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // return array of user models
    public func getUsers() -> [Note] {
         
        // create empty array
        var userModels: [Note] = []
     
        // get all users in descending order
        users = users.order(id.desc)
     
        // exception handling
        do {
     
            // loop through all users
            for user in try db.prepare(users) {
     
                // create new model in each loop iteration
                let userModel: Note = Note()
     
                // set values in model from database
                userModel.id = user[id]
                userModel.title = user[title]
                userModel.noteText = user[noteText]
              
     
                // append in new array
                userModels.append(userModel)
            }
        } catch {
            print(error.localizedDescription)
        }
     
        // return array
        return userModels
    }
    
    // get single user data
    public func getNote(idValue: Int64) -> Note {
     
        // create an empty object
        let userModel: Note = Note()
         
        // exception handling
        do {
     
            // get user using ID
            let user: AnySequence<Row> = try db.prepare(users.filter(id == idValue))
     
            // get row
            try user.forEach({ (rowValue) in
     
                // set values in model
                userModel.id = try rowValue.get(id)
                userModel.noteText = try rowValue.get(noteText)
                userModel.title = try rowValue.get(title)
               
            })
        } catch {
            print(error.localizedDescription)
        }
     
        // return model
        return userModel
    }
    
    
    
    // function to update user
    public func updateNote(idValue: Int64, titleValue: String, noteTextValue: String) {
        do {
            // get user using ID
            let user: Table = users.filter(id == idValue)
             
            // run the update query
            try db.run(user.update(title <- titleValue, noteText <- noteTextValue))
        } catch {
            print(error.localizedDescription)
        }
    }
    
 
  
        
    // function to delete user
    public func deleteNote(idValue: Int64) {
        do {
            // get user using ID
            let user: Table = users.filter(id == idValue)
             
            // run the delete query
            try db.run(user.delete())
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    
}
