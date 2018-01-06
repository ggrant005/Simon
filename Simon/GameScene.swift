//
//  GameScene.swift
//  Simon
//
//  Created by Greg Grant on 5/17/17.
//  Copyright © 2017 Greg Grant. All rights reserved.
//

import SpriteKit
import GameplayKit

enum GameState
{
  case startScreen
  case hostPattern
  case userPattern
  case deadReset
}

struct Color
{
  var mName: String
  var mColorUnpressed: UIColor
  var mColorPressed: UIColor
}

struct IPoint
{
  var mX: Int
  var mY: Int
  
  static func ==(lhs: IPoint, rhs: IPoint) -> Bool
  {
    return lhs.mX == rhs.mX && lhs.mY == rhs.mY
  }
}

struct Tile
{
  var mSpriteNode: SKSpriteNode
  var mPoint: IPoint
  var mSound: SKAction
  var mColor: Color
}

class GameScene: SKScene
{
  var mBoard = [[Tile]]()
  
  var mHostPattern = [IPoint]()
  
  var mLevel = 0
  
  var mTilesTapped = 0
  
  var mGameState = GameState.startScreen
  
  let mNumBoardCols = 2
  let mNumBoardRows = 2
  
  let mHostPatternLength = 1000
  
  let mDarkValue = CGFloat(204.0/255.0)
  
  var mWaitingForHostPattern = false
  
  var mBlueColor: Color!
  var mRedColor: Color!
  var mGreenColor: Color!
  var mYellowColor: Color!
  
  let mWait50ms = SKAction.wait(forDuration: 0.05)
  let mWait100ms = SKAction.wait(forDuration: 0.1)
  let mWait200ms = SKAction.wait(forDuration: 0.2)
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  override func didMove(to view: SKView)
  {
    createColors()
    createBoard()
    createHostPattern()
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
  {
    switch mGameState
    {
    case .startScreen:
      flashTiles(3)
      changeGameStateToHostPattern(milliseconds: 2000)
      
    case .hostPattern:
      break
      
    case .userPattern:
      evaluateTap(registerTap(touches))
      
    case .deadReset:
      break
    }
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  override func update(_ currentTime: TimeInterval)
  {
    switch mGameState
    {
    case .startScreen:
      break
      
    case .hostPattern:
      mGameState = .userPattern
      displayPattern(
        mHostPattern,
        patternIdx: 0,
        patternLength: mLevel,
        waitFor: mWait200ms)
      
    case .userPattern:
      break
      
    case .deadReset:
      if !mWaitingForHostPattern
      {
        mWaitingForHostPattern = true
        flashTiles(3)
        mTilesTapped = 0
        mLevel = 0
        resetHostPattern()
        changeGameStateToHostPattern(milliseconds: 2000)
      }
    }
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func changeGameStateToHostPattern(milliseconds toWait: Int)
  {
    DispatchQueue.main.asyncAfter(
      deadline: DispatchTime.now() + .milliseconds(toWait))
    {
      self.mGameState = .hostPattern
      self.mWaitingForHostPattern = false
    }
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func createColors()
  {
    mBlueColor = Color(
      mName: "blue",
      mColorUnpressed: UIColor(
        red: 0,
        green: 0,
        blue: mDarkValue,
        alpha: 1),
      mColorPressed: UIColor(
        red: 0,
        green: 0,
        blue: 1,
        alpha: 1))
    
    mRedColor = Color(
      mName: "red",
      mColorUnpressed: UIColor(
        red: mDarkValue,
        green: 0,
        blue: 0,
        alpha: 1),
      mColorPressed: UIColor(
        red: 1,
        green: 0,
        blue: 0,
        alpha: 1))
    
    mGreenColor = Color(
      mName: "green",
      mColorUnpressed: UIColor(
        red: 0,
        green: mDarkValue,
        blue: 0,
        alpha: 1),
      mColorPressed: UIColor(
        red: 0,
        green: 1,
        blue: 0,
        alpha: 1))
    
    mYellowColor = Color(
      mName: "yellow",
      mColorUnpressed: UIColor(
        red: mDarkValue,
        green: mDarkValue,
        blue: 0,
        alpha: 1),
      mColorPressed: UIColor(
        red: 1,
        green: 1,
        blue: 0,
        alpha: 1))
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func createBoard()
  {
    for row in 0 ..< mNumBoardRows
    {
      mBoard.append([Tile]())
      
      for _ in 0 ..< mNumBoardCols
      {
        mBoard[row].append(Tile(
          mSpriteNode: SKSpriteNode(),
          mPoint: IPoint(mX: Int(), mY: Int()),
          mSound: SKAction(),
          mColor: Color(
            mName: String(),
            mColorUnpressed: UIColor(),
            mColorPressed: UIColor())))
      }
    }
    
    let quarterHeight = frame.height / 4
    let quarterWidth = frame.width / 4
    
    createTile(
      mBlueColor,
      at: CGPoint(x: -quarterWidth, y: quarterHeight),
      at: IPoint(mX: 0, mY: 1),
      with: SKAction.playSoundFileNamed(
        "43398747_beep-04.wav",
        waitForCompletion: false))
    
    createTile(
      mRedColor,
      at: CGPoint(x: quarterWidth, y: quarterHeight),
      at: IPoint(mX: 1, mY: 1),
      with: SKAction.playSoundFileNamed(
        "43398747_beep-04.wav",
        waitForCompletion: false))
    
    createTile(
      mGreenColor,
      at: CGPoint(x: -quarterWidth, y: -quarterHeight),
      at: IPoint(mX: 0, mY: 0),
      with: SKAction.playSoundFileNamed(
        "43398747_beep-04.wav",
        waitForCompletion: false))
    
    createTile(
      mYellowColor,
      at: CGPoint(x: quarterWidth, y: -quarterHeight),
      at: IPoint(mX: 1, mY: 0),
      with: SKAction.playSoundFileNamed(
        "43398747_beep-04.wav",
        waitForCompletion: false))
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func createTile(
    _ color: Color,
    at position: CGPoint,
    at boardPoint: IPoint,
    with sound: SKAction)
  {
    let spriteNode = SKSpriteNode(
      color: color.mColorUnpressed,
      size: CGSize(width: frame.width/2, height: frame.height/2))
    
    spriteNode.name = color.mName + "Tile"
    spriteNode.physicsBody = SKPhysicsBody(rectangleOf: spriteNode.size)
    spriteNode.physicsBody?.isDynamic = false
    spriteNode.position = position
    
    addChild(spriteNode)
    
    mBoard[boardPoint.mX][boardPoint.mY] = Tile(
      mSpriteNode: spriteNode,
      mPoint: boardPoint,
      mSound: sound,
      mColor: color)
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func createHostPattern()
  {
    for _ in 0 ..< mHostPatternLength
    {
      mHostPattern.append(randPoint())
    }
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func resetHostPattern()
  {
    for i in 0 ..< mHostPatternLength
    {
      mHostPattern[i] = randPoint()
    }
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func randPoint() -> IPoint
  {
    return IPoint(mX: randInt(mNumBoardCols), mY: randInt(mNumBoardRows))
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func randInt(_ max: Int) -> Int
  {
    return Int(arc4random_uniform(UInt32(max)))
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func registerTap(_ touches: Set<UITouch>) -> IPoint
  {
    let touch = touches.first!
    let location = touch.location(in: self)
    
    var boardPoint = IPoint(mX: Int(), mY: Int())
    for tileRow in mBoard as [[Tile]]
    {
      for tile in tileRow
      {
        if tile.mSpriteNode.contains(location)
        {
          boardPoint = tile.mPoint
          tile.mSpriteNode.run(cycleColor(
            tile.mSpriteNode,
            boardPoint: boardPoint,
            waitFor: mWait100ms))
          break
        }
      }
    }
    
    return boardPoint
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func evaluateTap(_ userTappedPoint: IPoint)
  {
    let PatternPoint = mHostPattern[mTilesTapped]
    if userTappedPoint == PatternPoint // entered correct tile
    {
      if mTilesTapped == mLevel // correctly finished pattern
      {
        mLevel += 1
        mTilesTapped = 0
        changeGameStateToHostPattern(milliseconds: 500)
      }
      else // tapping pattern
      {
        mTilesTapped += 1
      }
    }
    else // die, reset board
    {
      mGameState = .deadReset
    }
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func displayPattern(
    _ pattern: [IPoint],
    patternIdx: Int,
    patternLength: Int,
    waitFor: SKAction)
  {
    let colorPoint = pattern[patternIdx]
    let tileNode = mBoard[colorPoint.mX][colorPoint.mY].mSpriteNode
    
    let sequence = cycleColor(
      tileNode,
      boardPoint: colorPoint,
      waitFor: waitFor)
    
    if patternIdx == patternLength
    {
      tileNode.run(sequence)
    }
    else
    {
      tileNode.run(sequence, completion:
      {
        self.displayPattern(
          pattern,
          patternIdx: patternIdx + 1,
          patternLength: patternLength,
          waitFor: waitFor)
      })
    }
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func flashTiles(_ revs: Int)
  {
    let cycle = [
      IPoint(mX: 0, mY: 0),
      IPoint(mX: 0, mY: 1),
      IPoint(mX: 1, mY: 1),
      IPoint(mX: 1, mY: 0) ]
    var pattern = [IPoint]()
    
    for _ in 0 ... revs
    {
      pattern += cycle
    }
    
    displayPattern(
      pattern,
      patternIdx: 0,
      patternLength: pattern.count - 1,
      waitFor: mWait50ms)
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func cycleColor(
    _ node: SKSpriteNode,
    boardPoint: IPoint,
    waitFor: SKAction) -> SKAction
  {
    return SKAction.sequence([
      waitFor,
      pressColor(node, boardPoint: boardPoint),
      mBoard[boardPoint.mX][boardPoint.mY].mSound,
      waitFor,
      unpressColor(node, boardPoint: boardPoint)])
  }

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func pressColor(_ tileNode: SKSpriteNode!, boardPoint: IPoint) -> SKAction
  {
    return SKAction.run
    {
      tileNode.color =
        self.mBoard[boardPoint.mX][boardPoint.mY].mColor.mColorPressed
    }
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func unpressColor(_ tileNode: SKSpriteNode!, boardPoint: IPoint) -> SKAction
  {
    return SKAction.run
    {
      tileNode.color =
        self.mBoard[boardPoint.mX][boardPoint.mY].mColor.mColorUnpressed
    }
  }
}
