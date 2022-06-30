//
//  EditUserView.swift
//  Pods
//
//  Created by user on 27/06/22.

//@Binding is used when you want to pass the value from one view to another. In that case, if you are using preview provider, then you have to create the @State variable in it.
//

import Foundation
import SwiftUI
 
struct EditNoteView: View {
     
    // id receiving of user from previous view
    @Binding var id: Int64
     
    // variables to store value from input fields
    @State var title: String = ""
    @State var noteText: String = ""
    
     
    // to go back to previous view
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
     
    var body: some View {
        VStack {
            // create name field
            TextField("Enter title", text: $title)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(5)
                .disableAutocorrection(true)
             
            // create email field
            TextField("Enter text", text: $noteText)
                .padding(40)
                .background(Color(.systemGray6))
                .cornerRadius(5)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
             

            // button to update user
            Button(action: {
                // call function to update row in sqlite database
                DB_Manager().updateNote(idValue: self.id, titleValue: self.title, noteTextValue: self.noteText)
 
                // go back to home page
                self.mode.wrappedValue.dismiss()
            }, label: {
                Text("Edit Text")
            })
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.top, 10)
                .padding(.bottom, 10)
        }.padding()
 
        // populate user's data in fields when view loaded
        .onAppear(perform: {
             
            // get data from database
            let userModel: Note = DB_Manager().getNote(idValue: self.id)
             
            // populate in text fields
            self.title = userModel.title
            self.noteText = userModel.noteText
        })
    }
}
 
struct EditUserView_Previews: PreviewProvider {
     
    // when using @Binding, do this in preview provider
    @State static var id: Int64 = 0
     
    static var previews: some View {
        EditNoteView(id: $id)
    }
}
