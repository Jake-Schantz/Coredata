//
//  ViewController.swift
//  50-coreData
//
//  Created by Jacob Schantz on 11/1/17.
//  Copyright © 2017 Jacob Schantz. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var studentTableView: UITableView!
    
    var fetchResultController = NSFetchedResultsController<Student>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        studentTableView.dataSource = self
        studentTableView.delegate = self
        fetchStudent()
    }
    
    
    
    
    func fetchStudent(){
        let fetchRequest = NSFetchRequest<Student>(entityName: "Student")
        
//        let filter = NSPredicate(format: "name BEGINSWITH %@", "A")
//        fetchRequest.predicate = filter
        let sort = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.moc, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchResultController.delegate = self
        
        do {
            try fetchResultController.performFetch()
//            let storeStudents = try DataController.moc.fetch(fetchRequest)
            
//            students = storeStudents
            studentTableView.reloadData()
            
        } catch {
            print("error fetching student")
        }
    }
    
    
    
    
    @IBAction func addButtonTapped(_ sender: Any) {
        
        guard let input = textField.text, input != ""
            else{
            print("invalid Input")
            return
        }
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Student", in: DataController.moc)
            else{
                print("entity student not found")
                return
        }
        let newStudent = Student(entity: entityDescription, insertInto: DataController.moc)
        newStudent.name = input
        newStudent.age = Int16(arc4random_uniform(64))
        newStudent.id = "\(1421321 + Int(arc4random_uniform(100)))"
        
//        let indexPath = IndexPath(row: students.count-1, section: 0)
//        studentTableView.insertRows(at: [indexPath], with: .right)
//
//        DataController.saveContext()
    }

}
extension ViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return students.count
        return fetchResultController.fetchedObjects?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell", for: indexPath)
        
//        let currentStudent = students[indexPath.row]
        let currentStudent = fetchResultController.object(at: indexPath)
        cell.textLabel?.text = currentStudent.name
        return cell
    }
}

extension ViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedStudent = fetchResultController.object(at: indexPath)

        let alert = UIAlertController(title: "details", message: "", preferredStyle: .alert)

        alert.addTextField{ (tf1) in
            tf1.text = selectedStudent.name
            tf1.placeholder = "Name Of Student"
        }
        alert.addTextField{ (tf2) in
            tf2.text = selectedStudent.id
            tf2.placeholder = "id Of Student"
        }
        alert.addTextField{ (tf3) in
            tf3.text = "\(selectedStudent.age)"
            tf3.placeholder = "Age of student"
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel , handler: nil)
        let save = UIAlertAction(title: "Save", style: .default) { (action) in
            guard let name = alert.textFields?[0].text,
            let id = alert.textFields?[1].text,
            let ageString = alert.textFields?[2].text,
            let age = Int16(ageString)
            else {return}

            selectedStudent.name = name
            selectedStudent.id = id
            selectedStudent.age = age

//            self.studentTableView.reloadRows(at: [indexPath], with: .bottom)

        }
        let delete = UIAlertAction(title: "Delete", style: .destructive) { (action) in
//            self.students.remove(at: indexPath.row)
//            self.studentTableView.deleteRows(at: [indexPath], with: .left)

            DataController.moc.delete(selectedStudent)

        }

        alert.addAction(cancel)
        alert.addAction(save)
        alert.addAction(delete)
        present(alert,animated: true,completion: nil)
    }

}
extension ViewController : NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("will change")
        studentTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let index = newIndexPath{
                studentTableView.insertRows(at: [index], with: .right)
            }
        case .update:
            if let index = indexPath{
                studentTableView.reloadRows(at: [index], with: .fade)
            }
        case .delete:
            if let index = indexPath{
                studentTableView.deleteRows(at: [index], with: .fade)
            }
        case .move:
            if let fromIndex = indexPath,
                let toIndex =  newIndexPath {
                studentTableView.deleteRows(at: [fromIndex], with: .none)
                studentTableView.insertRows(at: [toIndex], with: .none)
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("did change")
        studentTableView.endUpdates()

    }
    
    
}
