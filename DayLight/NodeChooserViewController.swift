//
//  NodeChooserTableViewController.swift
//  EGaaS
//
//  Created by Andrei Nechaev on 12/21/16.
//  Copyright © 2016 Andrei Nechaev. All rights reserved.
//

import UIKit

class NodeChooserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var nodesTableView: UITableView!
    
    var nodes = [String]()
    var chosenNode: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        nodesTableView.backgroundColor = UIColor(hue:0.541, saturation:0.899, brightness:0.545, alpha:1)
        loadNodes()
//        nodes.append("https://node001.egaas.org")
    }
    
    func loadNodes() {
        let url = URL(string: "http://egaas.org/nodes")!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data, error == nil {
                if let nodeString = String(data: data, encoding: String.Encoding.utf8) {
                    for cmp in nodeString.components(separatedBy: "\n") {
                        let trimmed = cmp.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        if trimmed != "" {
                            self.nodes.append("http://" + cmp)
                        }
                    }
                    DispatchQueue.main.async {
                        self.nodesTableView.reloadData()
                    }
                }
                
                print(String(data: data, encoding: String.Encoding.utf8) ?? "no data")
            }
        }
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return nodes.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NodeCellId", for: indexPath)
        cell.backgroundColor = UIColor(hue:0.539, saturation:0.649, brightness:0.906, alpha:1)
        cell.textLabel?.text = nodes[indexPath.row]
        chosenNode = nodes[indexPath.row]

        return cell
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "toViewController", chosenNode != nil {
            let vc = segue.destination as! ViewController
            vc.poolURL = URL(string: chosenNode!)
        }
    }

}
