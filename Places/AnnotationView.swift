/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

protocol AnnotationViewDelegate {
  func didTouch(annotationView: AnnotationView)
}


class AnnotationView: ARAnnotationView {
  var titleLabel: UILabel?
  var distanceLabel: UILabel?
  var imageLabel: UILabel?
  var delegate: AnnotationViewDelegate?
  var isProduct: Bool?
  
  override func didMoveToSuperview() {
    super.didMoveToSuperview()
    loadUI()
  }
  
  func loadUI() {
    titleLabel?.removeFromSuperview()
    distanceLabel?.removeFromSuperview()
    imageLabel?.removeFromSuperview()
  
    imageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
    imageLabel?.numberOfLines = 0
    
    if let annotation = annotation as? Place {
      imageLabel?.text = ""
      imageLabel?.addImage(imageName: annotation.reference)
      imageLabel?.tag = annotation.tag!
      if annotation.address == "nil" {
        imageLabel?.backgroundColor = UIColor(white: 0.3, alpha: 0.7)
      }
    }
    self.addSubview(imageLabel!)
  }
  
  
  override func layoutSubviews() {
    super.layoutSubviews()
    imageLabel?.frame = CGRect(x: 0, y: 0, width: 500, height: 200)
    if let annotation = annotation as? Place {
      if annotation.address == "nil" {
        imageLabel?.frame = CGRect(x: 0, y: 0, width: 150, height: 200)
      }
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    delegate?.didTouch(annotationView: self)
  }
}

extension UILabel
{
  func addImage(imageName: String)
  {
    let attachment:NSTextAttachment = NSTextAttachment()
    attachment.image = UIImage(named: imageName)
    let attachmentString:NSAttributedString = NSAttributedString(attachment: attachment)
    let myString:NSMutableAttributedString = NSMutableAttributedString(string: self.text!)
    myString.append(attachmentString)
    
    self.attributedText = myString
  }
}
