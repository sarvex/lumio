//
//  GameLayer.m
//  CircleGame
//
//  Created by Joanne Dyer on 1/19/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


// Import the interfaces
#import "GameLayer.h"
#import "Light.h"
#import "Route.h"
#import "Player.h"
#import "CountdownBar.h"
#import "Level.h"
#import "GameConfig.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#pragma mark - GameLayer

@interface GameLayer ()

@property (nonatomic, strong) Player *player;
@property (nonatomic, strong) Route *route;
@property (nonatomic, strong) NSMutableArray *twoDimensionallightArray;
@property (nonatomic, strong) CountdownBar * countdownBar;
@property (nonatomic, strong) Level *level;

@end

// HelloWorldLayer implementation
@implementation GameLayer

@synthesize player = _player;
@synthesize route = _route;
@synthesize twoDimensionallightArray = _twoDimensionallightArray;
@synthesize countdownBar = _countdownBar;
@synthesize level = _level;

// Helper class method that creates a Scene with the GameLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameLayer *layer = [GameLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {

        // ask director for the window size
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        CCSprite *background;
        
        if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
            background = [CCSprite spriteWithFile:@"GreyBackground.png"];
            //background.rotation = 90;
        } else {
            background = [CCSprite spriteWithFile:@"GreyBackground.png"];
        }
        background.position = ccp(size.width/2, size.height/2);

        // add the label as a child to this Layer
        [self addChild: background z:0];
        
        //create the player object and add it to layer.
        self.player = [[Player alloc] init];
        //TODO set position and add to layer.
        
        // create and initialize our light effects.
        self.twoDimensionallightArray = [NSMutableArray array];
        for (int row = 0; row < NUMBER_OF_ROWS; row++) {
            NSMutableArray *innerArray = [NSMutableArray array];
            for (int column = 0; column < NUMBER_OF_COLUMNS; column++) {
                struct GridLocation gridLocation = {row, column};
                Light *light = [[Light alloc] initWithGameLayer:self gridLocation:gridLocation];
                light.position = ccp(GAME_AREA_X_COORD + GAME_AREA_WIDTH /NUMBER_OF_COLUMNS * (column + 0.5f), GAME_AREA_Y_COORD + GAME_AREA_HEIGHT / NUMBER_OF_ROWS * (row + 0.5f));
                [innerArray addObject:light];
            }
            [self.twoDimensionallightArray addObject:innerArray];
        }
        
        //create the route object.
        self.route = [[Route alloc] initWithGameLayer:self lightArray:self.twoDimensionallightArray];
        
        //create the countdown bar and set its position.
        self.countdownBar = [[CountdownBar alloc] initWithGameLayer:self];
        self.countdownBar.position = ccp(COUNTDOWN_BAR_X_COORD, COUNTDOWN_BAR_Y_COORD);
        
        //create the level object and set its position.
        self.level = [[Level alloc] initWithGameLayer:self countdownBar:self.countdownBar];
        self.level.position = ccp(LEVEL_X_COORD, LEVEL_Y_COORD);
        
        //add the player starting position to the route. Choose a light near the middle.
        Light *firstLight = [[self.twoDimensionallightArray objectAtIndex:4] objectAtIndex:3];
        [self.route setInitialLight:firstLight];
        
        //add the player and set it to the first light position.
        self.player = [[Player alloc] initWithGameLayer:self route:self.route currentLight:firstLight countdownBar:self.countdownBar];
    
        self.isTouchEnabled = YES;
    
        [self schedule:@selector(update:)];
        

	}
	return self;
}

//update method calls similar methods on Light and player to manage transition of lights and movement of player.
- (void)update:(ccTime)dt {
    for (NSMutableArray *innerArray in self.twoDimensionallightArray) {
        for (Light *light in innerArray) {
            [light update:dt];
        }
    }
    [self.player update:dt];
    [self.countdownBar update:dt];
    [self.level update:dt];
}

- (void)registerWithTouchDispatcher
{
	[[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    return YES;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [self convertTouchToNodeSpace:touch];
    
    //go through all the lights seeing if they were touched.
    for (NSMutableArray *innerArray in self.twoDimensionallightArray) {
        for (Light *light in innerArray) {
            if (CGRectContainsPoint([light getBounds], location)) {
                [self.route lightSelected:light];
                break;
            }
        }
    }
}

@end
