#import <XCTest/XCTest.h>

#import "MetalImageMath.h"
#import "MetalImageTypes.h"

@interface MetalImageMathTests : XCTestCase
@end

@implementation MetalImageMathTests

- (void)testGaussianDistributionNormalizesToOne
{
    float buffer[4] = {0};
    make_gaussian_distribution(3, 1.5f, true, buffer);

    float sum = buffer[0];
    for (NSUInteger i = 1; i < 4; i++) {
        sum += 2.0f * buffer[i];
    }

    XCTAssertEqualWithAccuracy(sum, 1.0f, 0.0001f);
    XCTAssertGreaterThan(buffer[0], buffer[1]);
    XCTAssertGreaterThan(buffer[1], buffer[2]);
    XCTAssertGreaterThan(buffer[2], buffer[3]);
}

- (void)testGaussianDistributionWithoutNormalizationKeepsPeakValue
{
    float buffer[3] = {0};
    make_gaussian_distribution(2, 1.0f, false, buffer);

    XCTAssertEqualWithAccuracy(buffer[0], 1.0f, 0.0001f);
    XCTAssertLessThan(buffer[1], buffer[0]);
    XCTAssertLessThan(buffer[2], buffer[1]);
}

- (void)testGaussian2DDistributionNormalizesAndRemainsSymmetric
{
    const unsigned int radius = 2;
    const unsigned int width = radius * 2 + 1;
    float buffer[25] = {0};

    make_gaussian_distribution_2d(radius, 1.2f, true, buffer);

    float sum = 0.0f;
    for (NSUInteger i = 0; i < width * width; i++) {
        sum += buffer[i];
    }

    const NSUInteger center = radius * width + radius;
    XCTAssertEqualWithAccuracy(sum, 1.0f, 0.0001f);
    XCTAssertEqualWithAccuracy(buffer[0], buffer[(width - 1) * width + (width - 1)], 0.0001f);
    XCTAssertEqualWithAccuracy(buffer[center - 1], buffer[center + 1], 0.0001f);
    XCTAssertEqualWithAccuracy(buffer[center - width], buffer[center + width], 0.0001f);
    XCTAssertGreaterThan(buffer[center], buffer[0]);
}

- (void)testRenderingCoordinateFactoryPreservesInputs
{
    MTLRenderingPoint lowerLeft = MTLRenderingPointMake(-1.0f, -1.0f);
    MTLRenderingPoint lowerRight = MTLRenderingPointMake(1.0f, -1.0f);
    MTLRenderingPoint upperRight = MTLRenderingPointMake(1.0f, 1.0f);
    MTLRenderingPoint upperLeft = MTLRenderingPointMake(-1.0f, 1.0f);

    MTLRenderingCoordinate coordinate =
        MTLRenderingCoordinateMake(lowerLeft, lowerRight, upperRight, upperLeft);

    XCTAssertEqual(coordinate.lowerLeft.x, lowerLeft.x);
    XCTAssertEqual(coordinate.lowerLeft.y, lowerLeft.y);
    XCTAssertEqual(coordinate.lowerRight.x, lowerRight.x);
    XCTAssertEqual(coordinate.upperRight.y, upperRight.y);
    XCTAssertEqual(coordinate.upperLeft.x, upperLeft.x);
}

- (void)testVectorHelpersReturnExpectedValues
{
    MTLVector vector = MTLVectorMake(3.0f, 4.0f);
    XCTAssertEqualWithAccuracy(MTLVectorLength(&vector), 5.0f, 0.0001f);

    MTLFloat4 value = MTLFloat4Make(1.0f, 2.0f, 3.0f, 4.0f);
    XCTAssertEqual(value.x, 1.0f);
    XCTAssertEqual(value.y, 2.0f);
    XCTAssertEqual(value.z, 3.0f);
    XCTAssertEqual(value.w, 4.0f);
}

- (void)testIntegerHelpersSwapAndCompare
{
    MTLInt2 pair = MTLInt2Make(7, 9);
    MTLInt2Swap(&pair);
    XCTAssertTrue(MTLInt2Equal(pair, MTLInt2Make(9, 7)));
    XCTAssertTrue(MTLInt2IsZero(MTLInt2Zero));

    MTLInt3 first = MTLInt3Make(1, 2, 3);
    MTLInt3 second = MTLInt3Make(4, 5, 6);
    MTLInt3Swap(&first, &second);
    XCTAssertTrue(MTLInt3Equal(first, MTLInt3Make(4, 5, 6)));
    XCTAssertTrue(MTLInt3Equal(second, MTLInt3Make(1, 2, 3)));

    MTLUInt2 unsignedPair = MTLUInt2Make(8, 11);
    MTLUInt2Swap(&unsignedPair);
    XCTAssertTrue(MTLUInt2Equal(unsignedPair, MTLUInt2Make(11, 8)));
    XCTAssertTrue(MTLUInt2IsZero(MTLUInt2Zero));
}

@end
