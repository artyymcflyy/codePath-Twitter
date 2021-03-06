//
//  TweetsViewController.swift
//  Twitter
//
//  Created by Arthur Burgin on 4/12/17.
//  Copyright © 2017 Arthur Burgin. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NewTweetViewControllerDelegate, UIScrollViewDelegate{
    
    @IBOutlet var tableView: UITableView!
    var tweets: [Tweet]!
    var isMoreDataLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ntd = NewTweetViewController()
        ntd.delegate = self
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshAction(_:)), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        TwitterClient.sharedInstance?.homeTimeLine(success: { (tweets:[Tweet]) in
            self.tweets = tweets
            self.tableView.reloadData()
            
        }, failure: { (error:Error) in})
        
    }
    
    func refreshAction(_ refreshControl: UIRefreshControl){
        TwitterClient.sharedInstance?.homeTimeLine(success: { (tweets:[Tweet]) in
            self.tweets = tweets
            self.tableView.reloadData()
            refreshControl.endRefreshing()
        }, failure: { (error:Error) in
        })
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                
                isMoreDataLoading = true
                
                TwitterClient.sharedInstance?.homeTimeLine(success: { (tweets:[Tweet]) in
                    self.tweets = tweets
                    self.isMoreDataLoading = false
                    self.tableView.reloadData()
                }, failure: { (error:Error) in
                })
            }
        }
        
    }
    
    @IBAction func onLogout(_ sender: UIBarButtonItem) {
        TwitterClient.sharedInstance?.logout()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tweets != nil{
            return tweets.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //performSegue(withIdentifiezr: "TweetDetail", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell") as! TweetCell
        let tweet = tweets[indexPath.row]
        
        cell.nameLabel.text = tweet.name
        cell.usernameLabel.text = tweet.screenname
        cell.tweetLabel.text = tweet.text
        cell.timestampLabel.text = tweet.currTimeStamp
        cell.retweetCountLabel.text = "\(tweet.retweetCount)"
        cell.favoriteCountLabel.text = "\(tweet.favoritesCount)"
        
        if cell.tweetLabel.text?.range(of: "RT") == nil{
            cell.retweetedUsernameLabel.removeFromSuperview()
            cell.retweetedImageView.removeFromSuperview()
            
        }else{
            cell.contentView.addSubview(cell.retweetedImageView)
            cell.contentView.addSubview(cell.retweetedUsernameLabel)
            
            let horizonalContraints = NSLayoutConstraint(item: cell.retweetedImageView, attribute:
                .leadingMargin, relatedBy: .equal, toItem: cell.contentView,
                                attribute: .leadingMargin, multiplier: 1.0,
                                constant: 44)
            
            let topContraints = NSLayoutConstraint(item: cell.retweetedImageView, attribute:
                .top, relatedBy: .equal, toItem: cell.contentView,
                                 attribute: .top, multiplier: 1.0, constant: 2)
            
            let horizontal3Contraints = NSLayoutConstraint(item: cell.retweetedImageView, attribute:
                .trailingMargin, relatedBy: .equal, toItem: cell.retweetedUsernameLabel,
                                 attribute: .leadingMargin, multiplier: 1.0,
                                 constant: -20)
            
            let alignContraints = NSLayoutConstraint(item: cell.retweetedUsernameLabel, attribute:
                .centerY, relatedBy: .equal, toItem: cell.retweetedImageView,
                      attribute: .centerY, multiplier: 1.0, constant: 0)
            
            let horizontal2Contraints = NSLayoutConstraint(item: cell.retweetedUsernameLabel, attribute:
                .leadingMargin, relatedBy: .equal, toItem: cell.retweetedImageView,
                                attribute: .trailingMargin, multiplier: 1.0,
                                constant: 5)
            
            let horizontal4Contraints = NSLayoutConstraint(item: cell.retweetedUsernameLabel, attribute:
                .trailingMargin, relatedBy: .lessThanOrEqual, toItem: cell.contentView,
                      attribute: .trailingMargin, multiplier: 1.0, constant: -100)
            
            cell.retweetedImageView.frame.size.width = 21
            cell.retweetedImageView.frame.size.height = 22
            
            
            cell.retweetedImageView.translatesAutoresizingMaskIntoConstraints = false
            cell.retweetedUsernameLabel.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([horizonalContraints, topContraints,horizontal2Contraints,horizontal3Contraints, horizontal4Contraints, alignContraints])
            
            cell.retweetedUsernameLabel.text = tweet.name! + " retweeted"
            cell.tweetLabel.text = tweet.retweetedText
            cell.nameLabel.text = tweet.retweetedName
            cell.usernameLabel.text = tweet.retweetedUsername
            cell.retweetCountLabel.text = "\(tweet.retweetedRetweets)"
            cell.favoriteCountLabel.text = "\(tweet.retweetedFavorites)"
        }
        if tweet.profileImageUrl != nil{
            cell.getImageFromURL(url: tweet.profileImageUrl!)
        }
        
        return cell
    }
    
    func newTweetViewController(NewTweetViewController: NewTweetViewController, didGetValue value: Tweet) {
        tweets.insert(value, at: 0)
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newTweetModal"{
            let ntvc = segue.destination as! NewTweetViewController
            ntvc.delegate = self
        }
        if segue.identifier == "TweetDetail"{
            let vc = segue.destination as! TweetDetailViewController
            let cell = sender as! TweetCell
            let indexPath = tableView.indexPath(for: cell)
            
            vc.tweet = tweets[(indexPath?.row)!]
            
        }
        
    }

}
