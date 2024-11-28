import UIKit
import FirebaseFirestore

class RSVPTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let db = Firestore.firestore()
    var rsvpUsers: [String] = [] // List of user IDs
    var userDetails: [(username: String, profilePic: UIImage?)] = [] // List of usernames and profile pictures
    var eventID: String = "" // Pass this from the previous view controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchRSVPUsers()
    }
    
    // Fetch user IDs from Firestore and then fetch usernames and profile pictures
    func fetchRSVPUsers() {
        db.collection("events").document(eventID).getDocument { (document, error) in
            if let error = error {
                print("Error fetching event: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, let data = document.data() else {
                print("No event document found.")
                return
            }
            
            // Get the list of user IDs from peopleAttending
            if let attendees = data["peopleAttending"] as? [String] {
                self.rsvpUsers = attendees
                self.fetchUserDetails()
            } else {
                print("No attendees found.")
            }
        }
    }
    
    // Fetch usernames and profile pictures based on user IDs
    func fetchUserDetails() {
        let group = DispatchGroup() // To synchronize multiple network calls
        
        for userID in rsvpUsers {
            group.enter()
            db.collection("users").document(userID).getDocument { (document, error) in
                if let error = error {
                    print("Error fetching user: \(error.localizedDescription)")
                }
                
                if let document = document, let data = document.data() {
                    let username = data["username"] as? String ?? "Unknown User"
                    let profilePicBase64 = data["profilePic"] as? String
                    let profilePic = self.decodeBase64ToImage(profilePicBase64)
                    
                    self.userDetails.append((username: username, profilePic: profilePic))
                }
                group.leave()
            }
        }
        
        // Reload the table view after fetching all usernames and profile pictures
        group.notify(queue: .main) {
            self.tableView.reloadData()
        }
    }
    
    // Decode Base64 to UIImage
    func decodeBase64ToImage(_ base64String: String?) -> UIImage? {
        guard let base64String = base64String, let imageData = Data(base64Encoded: base64String) else { return nil }
        return UIImage(data: imageData)
    }
    
    // Table View Data Source Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RSVPCell", for: indexPath) as? RSVPTableViewCell else {
            fatalError("Unable to dequeue RSVPTableViewCell")
        }
        
        let userDetail = userDetails[indexPath.row]
        cell.usernameLabel.text = userDetail.username
        
        // Set the profile picture
        if let profilePic = userDetail.profilePic {
            cell.profilePic.image = profilePic
        } else {
            cell.profilePic.image = UIImage(systemName: "person.crop.circle") // Default profile image
        }
        
        // Customize profile image styling
        cell.profilePic.layer.cornerRadius = cell.profilePic.frame.width / 2
        cell.profilePic.clipsToBounds = true
        cell.profilePic.contentMode = .scaleAspectFill
        
        return cell
    }
}
